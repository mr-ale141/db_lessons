<?php

declare(strict_types=1);

namespace App\Domain\Employee;

use App\Domain\Employee\Employee;

interface EmployeeRepositoryInterface
{
    public function findOne(int $id): ?Employee;
    public function findByEmail(string $email): ?Employee;
    public function getListForDepartment(int $departmentId): array;

    public function save(Employee $employee): int;

    public function delete(int $id): void;
}
