<?php

declare(strict_types=1);

namespace App\Infrastructure\Persistence\Department;

use App\Domain\Department\Department;
use App\Domain\Department\DepartmentListRow;
use App\Domain\Department\DepartmentRepositoryInterface;
use App\Infrastructure\Database\Connection;
use Exception;
use PDO;
use RuntimeException;

class DepartmentRepository implements DepartmentRepositoryInterface
{
    private Connection $connection;

    public function __construct(Connection $connection)
    {
        $this->connection = $connection;
    }

    public function findOne(int $id): ?Department
    {
        $query = <<<SQL
            SELECT
              *
            FROM department
            WHERE id = ?
            SQL;
        $params = [$id];
        $stmt = $this->connection->execute($query, $params);

        if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            return $this->hydrateDepartment($row);
        }
        return null;
    }

    public function getDepartments(): array
    {
        $query = <<<SQL
            SELECT
              *
            FROM department
            ORDER BY city
            SQL;
        $stmt = $this->connection->execute($query);

        return array_map(
            fn($row) => $this->hydrateDepartment($row),
            $stmt->fetchAll(PDO::FETCH_ASSOC)
        );
    }

    public function getDepartmentList(): array
    {
        $query = <<<SQL
            SELECT
                d.id, d.city, d.address, d.zip_code, d.phone, d.email, count(e.id) AS size
            FROM department d
                LEFT JOIN bad_roads.employee e on d.id = e.department_id
            GROUP BY d.id
            ORDER BY d.id
            SQL;
        $stmt = $this->connection->execute($query);

        return array_map(
            fn($row) => $this->hydrateListDepartments($row),
            $stmt->fetchAll(PDO::FETCH_ASSOC)
        );
    }

    private function hydrateListDepartments(array $row): DepartmentListRow
    {
        try {
            return new DepartmentListRow(
                (int)$row['id'],
                (string)$row['city'],
                (string)$row['address'],
                (int)$row['zip_code'],
                (string)$row['phone'],
                (int)$row['size'],
                (string)$row['email'],
            );
        } catch (Exception $e) {
            throw new RuntimeException($e->getMessage(), $e->getCode(), $e);
        }
    }

    private function hydrateDepartment(array $row): Department
    {
        try {
            return new Department(
                (string)$row['city'],
                (string)$row['address'],
                (int)$row['zip_code'],
                (string)$row['phone'],
                (string)$row['email'],
                (int)$row['id'],
            );
        } catch (Exception $e) {
            throw new RuntimeException($e->getMessage(), $e->getCode(), $e);
        }
    }

    public function save(Department $department): int
    {
        $departmentId = $department->getId();
        if ($departmentId) {
            $this->updateDepartment($department);
        } else {
            $departmentId = $this->insertDepartment($department);
            $department->assignIdentifier($departmentId);
        }

        return $departmentId;
    }

    public function delete(int $id): void
    {
        if ($id === 0) {
            return;
        }

        $this->connection->execute(
            <<<SQL
            DELETE FROM department WHERE id = ?
            SQL,
            [$id]
        );
    }

    private function insertDepartment(Department $department): int
    {
        $query = <<<SQL
            INSERT INTO department (city, address, zip_code, phone, email)
            VALUES (:city, :address, :zip_code, :phone, :email)
            SQL;
        $params = [
            ':city' => $department->getCity(),
            ':address' => $department->getAddress(),
            ':zip_code' => $department->getZipCode(),
            ':phone' => $department->getPhone(),
            ':email' => $department->getEmail()
        ];

        $this->connection->execute($query, $params);

        return $this->connection->getLastInsertId();
    }

    private function updateDepartment(Department $department): void
    {
        $query = <<<SQL
            UPDATE department
            SET
                id = :id,
                city = :city, 
                address = :address, 
                zip_code = :zip_code, 
                phone = :phone, 
                email = :email
            WHERE id = :id
            SQL;
        $params = [
            ':id' => $department->getId(),
            ':city' => $department->getCity(),
            ':address' => $department->getAddress(),
            ':zip_code' => $department->getZipCode(),
            ':phone' => $department->getPhone(),
            ':email' => $department->getEmail()
        ];

        $stmt = $this->connection->execute($query, $params);
        if (!$stmt->rowCount()) {
            throw new RuntimeException("Optimistic lock failed for article {$department->getId()}");
        }
    }
}
