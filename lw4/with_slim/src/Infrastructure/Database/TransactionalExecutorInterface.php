<?php

declare(strict_types=1);

namespace App\Infrastructure\Database;

use Closure;
use Throwable;

interface TransactionalExecutorInterface
{
    /**
     * Метод выполняет переданную функцию внутри открытой транзакции, в конце вызывая COMMIT либо ROLLBACK.
     *
     * @param Closure $action
     * @return mixed|void
     * @throws Throwable
     */
    public function doWithTransaction(Closure $action);
}
