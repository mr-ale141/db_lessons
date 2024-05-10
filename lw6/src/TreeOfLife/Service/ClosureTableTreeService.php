<?php
declare(strict_types=1);

namespace App\TreeOfLife\Service;

use App\Common\Database\Connection;
use App\TreeOfLife\Data\TreeOfLifeNodeData;
use App\TreeOfLife\Model\TreeOfLifeNode;
use App\TreeOfLife\Model\TreeOfLifeNodeDataInterface;

class ClosureTableTreeService implements TreeOfLifeServiceInterface
{
    private const int INSERT_BATCH_SIZE = 1000;

    private Connection $connection;

    public function __construct(Connection $connection)
    {
        $this->connection = $connection;
    }

    public function getNode(int $id): ?TreeOfLifeNodeData
    {
        $query = <<<SQL
        SELECT
          tn.id,
          tn.name,
          tn.extinct,
          tn.confidence
        FROM tree_of_life.tree_of_life_node tn
        WHERE tn.id = :id
        SQL;
        $row = $this->connection->execute($query, [':id' => $id])->fetch(\PDO::FETCH_ASSOC);

        return $row ? self::hydrateTreeNodeData($row) : null;
    }

    public function getTree(): TreeOfLifeNode
    {
        $query = <<<SQL
        SELECT
          tn.id,
          tn.name,
          tn.extinct,
          tn.confidence,
          t.ancestor_id,
          t.is_root
        FROM tree_of_life.tree_of_life_node tn
          LEFT JOIN tree_of_life.tree_of_life_closure_table t ON t.node_id = tn.id
        WHERE t.distance = 1 OR t.is_root = true
        SQL;

        $rows = $this->connection->execute($query)->fetchAll(\PDO::FETCH_ASSOC);

        return self::hydrateTree($rows);
    }

    public function getSubTree(int $id): TreeOfLifeNode
    {
        $query = <<<SQL
        SELECT
          tn.id,
          tn.name,
          tn.extinct,
          tn.confidence,
          (
              SELECT
                  t_sub.ancestor_id
              FROM tree_of_life.tree_of_life_node tn_sub
                INNER JOIN tree_of_life.tree_of_life_closure_table t_sub ON t_sub.node_id = tn_sub.id
              WHERE t_sub.distance = 1 AND tn_sub.id = tn.id
          ) AS ancestor_id,
          (tn.id = :id) AS is_root
        FROM tree_of_life.tree_of_life_node tn
          LEFT JOIN tree_of_life.tree_of_life_closure_table t ON tn.id = t.node_id
        WHERE t.ancestor_id = :id
        SQL;
        $rows = $this->connection->execute($query, [':id' => $id])->fetchAll(\PDO::FETCH_ASSOC);

        return self::hydrateTree($rows);
    }

    public function getNodePath(int $id): array
    {
        $query = <<<SQL
        WITH RECURSIVE cte AS
            (
                SELECT
                    t.node_id,
                    t.ancestor_id
                FROM tree_of_life.tree_of_life_node n
                    LEFT JOIN tree_of_life.tree_of_life_closure_table t on t.node_id = n.id
                WHERE t.distance = 1 AND n.id = :id
                UNION ALL
                SELECT
                    t.node_id,
                    t.ancestor_id
                FROM tree_of_life.tree_of_life_node n
                    INNER JOIN cte ON n.id = cte.ancestor_id
                    LEFT JOIN tree_of_life.tree_of_life_closure_table t on t.node_id = n.id
                WHERE t.distance = 1
            )
        SELECT
          tn.id,
          tn.name,
          tn.extinct,
          tn.confidence
        FROM cte
          INNER JOIN tree_of_life.tree_of_life_node tn ON tn.id = cte.node_id
        UNION ALL
        SELECT
            tn.id,
            tn.name,
            tn.extinct,
            tn.confidence
        FROM tree_of_life.tree_of_life_node tn
            LEFT JOIN tree_of_life.tree_of_life_closure_table t ON tn.id = t.node_id
        WHERE t.distance = 0 AND t.is_root = true
        SQL;
        $rows = $this->connection->execute($query, [':id' => $id])->fetchAll(\PDO::FETCH_ASSOC);

        return array_map(static fn(array $row) => self::hydrateTreeNodeData($row), $rows);
    }

    public function getParentNode(int $id): ?TreeOfLifeNodeData
    {
        $query = <<<SQL
        SELECT
          tn.id,
          tn.name,
          tn.extinct,
          tn.confidence
        FROM tree_of_life.tree_of_life_node tn
          INNER JOIN tree_of_life.tree_of_life_closure_table t on tn.id = t.ancestor_id
        WHERE t.distance = 1 AND t.node_id = :id
        SQL;
        $row = $this->connection->execute($query, [':id' => $id])->fetch(\PDO::FETCH_ASSOC);

        return $row ? self::hydrateTreeNodeData($row) : null;
    }

    public function getChildren(int $id): array
    {
        $query = <<<SQL
        SELECT
          tn.id,
          tn.name,
          tn.extinct,
          tn.confidence
        FROM tree_of_life.tree_of_life_node tn
          INNER JOIN tree_of_life.tree_of_life_closure_table t on tn.id = t.node_id
        WHERE t.distance = 1 AND t.ancestor_id = :id
        SQL;
        $rows = $this->connection->execute($query, [':id' => $id])->fetchAll(\PDO::FETCH_ASSOC);

        return array_map(static fn(array $row) => self::hydrateTreeNodeData($row), $rows);
    }

    public function saveTree(TreeOfLifeNode $root): void
    {
        $allNodes = $root->listNodes();

        // Вместо записи всех узлов за один запрос делим массив на части.
        /** @var TreeOfLifeNode[] $nodes */
        foreach (array_chunk($allNodes, self::INSERT_BATCH_SIZE) as $nodes)
        {
            $this->insertIntoNodeTable($nodes);
        }

        $this->saveClosureTableData($root);
    }

    public function addNode(TreeOfLifeNodeData $node, int $parentId): void
    {
        $this->doWithTransaction(function () use ($node, $parentId) {
            $this->insertIntoNodeTable([$node]);

            $query = <<<SQL
            INSERT INTO tree_of_life.tree_of_life_closure_table (node_id, ancestor_id, distance, is_root)
                SELECT :nodeId, ancestor_id, distance + 1, false
                FROM tree_of_life.tree_of_life_closure_table
                WHERE node_id = :parentId
                UNION ALL
                SELECT :nodeId, :nodeId, 0, false
            SQL;
            $this->connection->execute($query, [':nodeId' => $node->getId(),  ':parentId' => $parentId]);
        });
    }

    public function moveSubTree(int $id, int $newParentId): void
    {
        // Проверяем, что новый родитель является потомком узла или тем же узлом.
        $newParentPath = $this->getNodePath($newParentId);
        foreach ($newParentPath as $newParentAncestor)
        {
            if ($newParentAncestor->getId() === $id)
            {
                throw new \InvalidArgumentException("Cannot move node $id into descendant node $newParentId");
            }
        }

        $query = <<<SQL
        DELETE a FROM tree_of_life.tree_of_life_closure_table AS a
            JOIN tree_of_life.tree_of_life_closure_table AS d 
                ON a.node_id = d.node_id
            LEFT JOIN tree_of_life.tree_of_life_closure_table AS x
                ON x.ancestor_id = d.ancestor_id AND x.node_id = a.ancestor_id
        WHERE d.ancestor_id = :id AND x.ancestor_id IS NULL;
        SQL;
        $this->connection->execute($query, [':id' => $id]);

        $query = <<<SQL
        INSERT INTO tree_of_life.tree_of_life_closure_table 
            (node_id, ancestor_id, distance, is_root)
        SELECT 
            subtree.node_id,
            supertree.ancestor_id, 
            supertree.distance + subtree.distance + 1,
            false
        FROM tree_of_life.tree_of_life_closure_table AS supertree 
            INNER JOIN tree_of_life.tree_of_life_closure_table AS subtree
        WHERE 
            subtree.ancestor_id = :id AND supertree.node_id = :new_parent_id;
        SQL;
        $params = [ ':id' => $id , ':new_parent_id' => $newParentId ];
        $this->connection->execute($query, $params);
    }

    public function deleteSubTree(int $id): void
    {
        // Удаляем рекурсивным запросом всё поддерево заданного узла.
        // Удаляются только строки из tree_of_life_node, а строки из tree_of_life_closure_table будут удалены
        // за счёт ON DELETE CASCADE у внешнего ключа
        $query = <<<SQL
        DELETE FROM tree_of_life.tree_of_life_node
        WHERE id IN (
            SELECT node_id
            FROM tree_of_life.tree_of_life_closure_table
            WHERE ancestor_id = :id
        )
        SQL;
        $this->connection->execute($query, [':id' => $id]);
    }

    /**
     * @param callable $action
     * @return void
     */
    private function doWithTransaction(callable $action): void
    {
        $this->connection->beginTransaction();
        $commit = false;
        try
        {
            $action();
            $commit = true;
        }
        finally
        {
            if ($commit)
            {
                $this->connection->commit();
            }
            else
            {
                $this->connection->rollback();
            }
        }
    }

    private function saveClosureTableData(TreeOfLifeNode $root): void
    {
        $results = [];
        $ancestors = [];
        $this->addClosureTableDataRecursive($root, $results, $ancestors, true);
    }

    private function addClosureTableDataRecursive(TreeOfLifeNode $node, array &$results, array &$ancestors, bool $isRoot): void
    {
        $ancestors[] = $node->getId();
        foreach ($node->getChildren() as $child)
        {
            $this->addClosureTableDataRecursive($child, $results, $ancestors, false);
        }
        foreach ($ancestors AS $ancestor)
        {
            $results[] = new ClosureTableData(
                $node->getId(),
                $ancestor,
                sizeof($ancestors) -  array_search($ancestor, $ancestors) - 1,
                $isRoot
            );
        }
        $this->insertIntoTreeTable($results);
        $results = [];
        array_pop($ancestors);
    }

    /**
     * Записывает узлы в таблицу с информацией об узлах.
     *
     * @param TreeOfLifeNodeDataInterface[] $nodes
     * @return void
     */
    private function insertIntoNodeTable(array $nodes): void
    {
        $placeholders = self::buildInsertPlaceholders(count($nodes), 4);
        $query = <<<SQL
            INSERT INTO tree_of_life_node (id, name, extinct, confidence)
            VALUES $placeholders
            SQL;
        $params = [];
        foreach ($nodes as $node)
        {
            $params[] = $node->getId();
            $params[] = $node->getName();
            $params[] = (int)$node->isExtinct();
            $params[] = $node->getConfidence();
        }
        $this->connection->execute($query, $params);
    }

    /**
     * Записывает узлы в таблицу с информацией о структуре дерева
     *
     * @param ClosureTableData[] $nodes
     * @return void
     */
    private function insertIntoTreeTable(array $nodes): void
    {
        if (count($nodes) === 0)
        {
            return;
        }

        $placeholders = self::buildInsertPlaceholders(count($nodes), 4);
        $query = <<<SQL
            INSERT INTO tree_of_life.tree_of_life_closure_table (node_id, ancestor_id, distance, is_root)
            VALUES $placeholders
            SQL;
        $params = [];
        foreach ($nodes as $node)
        {
            $params[] = $node->getNodeId();
            $params[] = $node->getAncestorId();
            $params[] = $node->getDistance();
            $params[] = (int)$node->isRoot();
        }
        $this->connection->execute($query, $params);
    }

    /**
     * Генерирует строку с SQL-заполнителями для множественной записи через INSERT.
     * Результат может выглядеть так: "(?, ?), (?, ?), (?, ?)"
     *
     * @param int $rowCount
     * @param int $columnCount
     * @return string
     */
    private static function buildInsertPlaceholders(int $rowCount, int $columnCount): string
    {
        if ($rowCount <= 0 || $columnCount <= 0)
        {
            throw new \InvalidArgumentException("Invalid row count $rowCount or column count $columnCount");
        }

        $rowPlaceholders = '(' . str_repeat('?, ', $columnCount - 1) . '?)';
        return str_repeat("$rowPlaceholders, ", $rowCount - 1) . $rowPlaceholders;
    }

    /**
     * Преобразует набор результатов SQL-запроса в дерево с одним корнем.
     * Метод предполагает, что в наборе результатов есть ровно один результат с is_root=true.
     *
     * @param array<array<string,string|null>> $rows
     * @return TreeOfLifeNode
     */
    private static function hydrateTree(array $rows): TreeOfLifeNode
    {
        $nodesMap = self::hydrateNodesMap($rows);

        $root = null;
        foreach ($rows as $row)
        {
            $id = (int)$row['id'];
            if ($row['is_root'])
            {
                $root = $nodesMap[$id];
            }
            else
            {
                $parentId = (int)$row['ancestor_id'];
                $node = $nodesMap[$id];
                $parent = $nodesMap[$parentId];
                $parent->addChildUnsafe($node);
            }
        }
        return $root;
    }

    /**
     * Преобразует набор результатов SQL-запроса в словарь, где ключи - ID узлов, а значения - объекты.
     *
     * @param array<array<string,string|null>> $rows
     * @return TreeOfLifeNode[] - отображает ID узла на узел.
     */
    private static function hydrateNodesMap(array $rows): array
    {
        $nodes = [];
        foreach ($rows as $row)
        {
            $node = self::hydrateTreeNode($row);
            $nodes[$node->getId()] = $node;
        }
        return $nodes;
    }

    /**
     * Преобразует один результат SQL-запроса в объект, представляющий узел дерева.
     *
     * @param array<string,string|null> $row
     * @return TreeOfLifeNode
     */
    private static function hydrateTreeNode(array $row): TreeOfLifeNode
    {
        return new TreeOfLifeNode(
            (int)$row['id'],
            $row['name'],
            (bool)$row['extinct'],
            (int)$row['confidence']
        );
    }

    /**
     * Преобразует один результат SQL-запроса в объект, представляющий узел дерева без связей с другими узлами.
     *
     * @param array<string,string|null> $row
     * @return TreeOfLifeNodeData
     */
    private static function hydrateTreeNodeData(array $row): TreeOfLifeNodeData
    {
        return new TreeOfLifeNodeData(
            (int)$row['id'],
            $row['name'],
            (bool)$row['extinct'],
            (int)$row['confidence']
        );
    }
}
