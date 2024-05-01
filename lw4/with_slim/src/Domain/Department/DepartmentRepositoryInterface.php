<?php

declare(strict_types=1);

namespace App\Domain\Department;

use App\Domain\Department\Department;

interface DepartmentRepositoryInterface
{
    public function findOne(int $id): ?Department;
    public function getListDepartment(): array;

    public function save(Department $department): int;

    public function delete(int $id): void;
}
