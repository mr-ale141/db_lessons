<?php

declare(strict_types=1);

namespace App\Domain\Service;

use App\Infrastructure\Database\TransactionalExecutorInterface;
use App\Domain\Employee\Employee;
use App\Domain\DomainException\DomainRecordNotFoundException;
use App\Domain\Employee\EmployeeRepositoryInterface;
use Throwable;

readonly class EmployeeService
{
    public function __construct(
        private TransactionalExecutorInterface $transactionalExecutor,
        private EmployeeRepositoryInterface $employeeRepository
    ) {
    }

    /**
     * @param int $id
     * @return Employee
     * @throws DomainRecordNotFoundException
     */
    public function getEmployee(int $id): Employee
    {
        $employee = $this->employeeRepository->findOne($id);
        if (!$employee) {
            throw new DomainRecordNotFoundException("Cannot find employee with id $id");
        }
        return $employee;
    }

    public function getEmployeesByDepartmentId($id): array
    {
        return $this->employeeRepository->getListForDepartment($id);
    }

    /**
     * @throws Throwable
     */
    public function createEmployee(Employee $employee): int
    {
        return $this->transactionalExecutor->doWithTransaction(function () use ($employee) {
            return $this->employeeRepository->save($employee);
        });
    }

    /**
     * @param Employee $employee
     * @return void
     * @throws DomainRecordNotFoundException
     * @throws Throwable
     */
    public function editEmployee(Employee $employee): void
    {
        $this->transactionalExecutor->doWithTransaction(function () use ($employee) {
            $this->employeeRepository->save($employee);
        });
    }

    public function deleteEmployee(int $id): void
    {
        $this->employeeRepository->delete($id);
    }

    public function getEmployeeByEmail(string $email): ?Employee
    {
        return $employee = $this->employeeRepository->findByEmail($email);
    }
}
