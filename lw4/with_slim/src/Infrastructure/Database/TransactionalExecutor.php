<?php

declare(strict_types=1);

namespace App\Infrastructure\Database;

use Closure;
use Throwable;

class TransactionalExecutor implements TransactionalExecutorInterface
{
    private Connection $connection;

    public function __construct(Connection $connection)
    {
        $this->connection = $connection;
    }

    /**
     * Метод выполняет переданную функцию внутри открытой транзакции, в конце вызывая COMMIT либо ROLLBACK.
     *
     * @param Closure $action
     * @return mixed|void
     * @throws Throwable
     */
    public function doWithTransaction(Closure $action)
    {
        $this->connection->beginTransaction();
        try {
            $result = $action();
            $this->connection->commit();
            return $result;
        } catch (Throwable $exception) {
            $this->connection->rollBack();
            throw $exception;
        }
    }
}
