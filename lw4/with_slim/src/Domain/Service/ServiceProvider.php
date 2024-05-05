<?php

declare(strict_types=1);

namespace App\Domain\Service;

use App\Infrastructure\Database\ConnectionProvider;
use App\Infrastructure\Database\TransactionalExecutor;
use App\Infrastructure\Persistence\Department\DepartmentRepository;
use App\Infrastructure\Persistence\Employee\EmployeeRepository;

final class ServiceProvider
{
    private ?DepartmentService $departmentService = null;
    private ?EmployeeService $employeeService = null;
    private ?DepartmentRepository $departmentRepository = null;
    private ?EmployeeRepository $employeeRepository = null;

    public static function getInstance(): self
    {
        static $instance = null;
        if ($instance === null) {
            $instance = new self();
        }
        return $instance;
    }

    public function getDepartmentService(): DepartmentService
    {
        if ($this->departmentService === null) {
            $synchronization = new TransactionalExecutor(ConnectionProvider::getConnection());
            $this->departmentService = new DepartmentService($synchronization, $this->getDepartmentRepository());
        }
        return $this->departmentService;
    }

    public function getEmployeeService(): EmployeeService
    {
        if ($this->employeeService === null) {
            $synchronization = new TransactionalExecutor(ConnectionProvider::getConnection());
            $this->employeeService = new EmployeeService($synchronization, $this->getEmployeeRepository());
        }
        return $this->employeeService;
    }

    private function getDepartmentRepository(): DepartmentRepository
    {
        if ($this->departmentRepository === null) {
            $this->departmentRepository = new DepartmentRepository(ConnectionProvider::getConnection());
        }
        return $this->departmentRepository;
    }

    private function getEmployeeRepository(): EmployeeRepository
    {
        if ($this->employeeRepository === null) {
            $this->employeeRepository = new EmployeeRepository(ConnectionProvider::getConnection());
        }
        return $this->employeeRepository;
    }
}
