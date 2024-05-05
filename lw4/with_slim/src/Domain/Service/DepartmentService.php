<?php

declare(strict_types=1);

namespace App\Domain\Service;

use App\Infrastructure\Database\TransactionalExecutorInterface;
use App\Domain\Department\Department;
use App\Domain\DomainException\DomainRecordNotFoundException;
use App\Domain\Department\DepartmentRepositoryInterface;
use Throwable;

readonly class DepartmentService
{
    public function __construct(
        private TransactionalExecutorInterface $transactionalExecutor,
        private DepartmentRepositoryInterface $departmentRepository
    ) {
    }

    /**
     * @param int $id
     * @return Department
     * @throws DomainRecordNotFoundException
     */
    public function getDepartment(int $id): Department
    {
        $department = $this->departmentRepository->findOne($id);
        if (!$department) {
            throw new DomainRecordNotFoundException("Cannot find department with id $id");
        }
        return $department;
    }

    /**
     * @throws DomainRecordNotFoundException
     */
    public function getDepartments(): array
    {
        $department = $this->departmentRepository->getDepartments();
        if (!$department) {
            throw new DomainRecordNotFoundException("Cannot find departments");
        }
        return $department;
    }

    /**
     * @throws DomainRecordNotFoundException
     */
    public function getDepartmentList(): array
    {
        $departmentList = $this->departmentRepository->getDepartmentList();
        if (!$departmentList) {
            throw new DomainRecordNotFoundException("Cannot find departments");
        }
        return $departmentList;
    }

    /**
     * @throws Throwable
     */
    public function createDepartment(Department $department): int
    {
        return $this->transactionalExecutor->doWithTransaction(function () use ($department) {
            return $this->departmentRepository->save($department);
        });
    }

    /**
     * @param Department $department
     * @return void
     * @throws DomainRecordNotFoundException
     * @throws Throwable
     */
    public function editDepartment(Department $department): void
    {
        $this->transactionalExecutor->doWithTransaction(function () use ($department) {
            $this->departmentRepository->save($department);
        });
    }

    public function deleteDepartment(int $id): void
    {
        $this->departmentRepository->delete($id);
    }
}
