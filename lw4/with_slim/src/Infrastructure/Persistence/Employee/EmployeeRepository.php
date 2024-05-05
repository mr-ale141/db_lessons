<?php

declare(strict_types=1);

namespace App\Infrastructure\Persistence\Employee;

use App\Domain\Employee\Employee;
use App\Domain\Employee\EmployeeRepositoryInterface;
use App\Infrastructure\Database\Connection;
use App\Infrastructure\Database\DatabaseDateFormat;
use DateTimeImmutable;
use DateTimeZone;
use Exception;
use PDO;
use RuntimeException;

class EmployeeRepository implements EmployeeRepositoryInterface
{
    private Connection $connection;

    public function __construct(Connection $connection)
    {
        $this->connection = $connection;
    }

    public function findOne(int $id): ?Employee
    {
        $query = <<<SQL
            SELECT
              *
            FROM employee
            WHERE id = ?
            SQL;
        $params = [$id];
        $stmt = $this->connection->execute($query, $params);

        if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            return $this->hydrateEmployee($row);
        }
        return null;
    }

    public function findByEmail(string $email): ?Employee
    {
        $query = <<<SQL
            SELECT
              *
            FROM employee
            WHERE email = ?
            SQL;
        $params = [$email];
        $stmt = $this->connection->execute($query, $params);

        if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            return $this->hydrateEmployee($row);
        }
        return null;
    }

    /**
     * @param int $departmentId
     * @return Employee[]
     */
    public function getListForDepartment(int $departmentId): array
    {
        $query = <<<SQL
            SELECT
              *
            FROM employee
            WHERE department_id = ?
            ORDER BY firstname, lastname, middlename
            SQL;
        $params = [$departmentId];
        $stmt = $this->connection->execute($query, $params);

        return array_map(
            fn($row) => $this->hydrateEmployee($row),
            $stmt->fetchAll(PDO::FETCH_ASSOC)
        );
    }

    private function hydrateEmployee(array $row): Employee
    {
        try {
            return new Employee(
                (int)$row['department_id'],
                (string)$row['firstname'],
                (string)$row['middlename'],
                (string)$row['sex'],
                $this->parseDateTimeOrNull($row['birth_date']),
                (string)$row['address'],
                $this->parseDateTimeOrNull($row['employment']),
                (string)$row['position'],
                (int)$row['id'],
                (string)$row['lastname'],
                (float)$row['experience'],
                (string)$row['phone'],
                (string)$row['email'],
                (string)$row['password'],
            );
        } catch (Exception $e) {
            throw new RuntimeException($e->getMessage(), $e->getCode(), $e);
        }
    }

    private function parseDateTimeOrNull(?string $value): ?DateTimeImmutable
    {
        try {
            return ($value !== null) ? new DateTimeImmutable($value, new DateTimeZone('Etc/UTC')) : null;
        } catch (Exception $e) {
            throw new RuntimeException($e->getMessage(), $e->getCode(), $e);
        }
    }

    private function formatDateTimeOrNull(?DateTimeImmutable $dateTime): ?string
    {
        return $dateTime?->format(DatabaseDateFormat::MYSQL_DATETIME_FORMAT);
    }

    public function save(Employee $employee): int
    {
        $employeeId = $employee->getId();
        if ($employeeId) {
            $this->updateEmployee($employee);
        } else {
            $employeeId = $this->insertEmployee($employee);
            $employee->assignIdentifier($employeeId);
        }

        return $employeeId;
    }

    public function delete(int $id): void
    {
        if ($id === 0) {
            return;
        }

        $this->connection->execute(
            <<<SQL
            DELETE FROM employee WHERE id = ?
            SQL,
            [$id]
        );
    }

    private function insertEmployee(Employee $employee): int
    {
        $query = <<<SQL
            INSERT INTO employee (department_id, 
                                  firstname, 
                                  middlename, 
                                  lastname, 
                                  sex, 
                                  birth_date, 
                                  experience, 
                                  address, 
                                  phone, 
                                  email, 
                                  password, 
                                  employment, 
                                  position
            )
            VALUES (:department_id, 
                    :firstname, 
                    :middlename, 
                    :lastname, 
                    :sex, 
                    :birth_date, 
                    :experience, 
                    :address, 
                    :phone, 
                    :email, 
                    :password, 
                    :employment, 
                    :position
            )
            SQL;
        $params = [
            ':department_id' => $employee->getDepartmentId(),
            ':firstname' => $employee->getFirstName(),
            ':middlename' => $employee->getMiddleName(),
            ':lastname' => $employee->getLastName(),
            ':sex' => $employee->getSex(),
            ':birth_date' => $this->formatDateTimeOrNull($employee->getBirthDate()),
            ':experience' => $employee->getExperience(),
            ':address' => $employee->getAddress(),
            ':phone' => $employee->getPhone(),
            ':email' => $employee->getEmail(),
            ':password' => $employee->getPassword(),
            ':employment' => $this->formatDateTimeOrNull($employee->getEmployment()),
            ':position' => $employee->getPosition()
        ];

        $this->connection->execute($query, $params);

        return $this->connection->getLastInsertId();
    }

    private function updateEmployee(Employee $employee): void
    {
        $query = <<<SQL
            UPDATE employee
            SET
                id = :id,
                department_id = :department_id, 
                firstname = :firstname, 
                middlename = :middlename, 
                lastname = :lastname, 
                sex = :sex, 
                birth_date = :birth_date, 
                experience = :experience, 
                address = :address, 
                phone = :phone, 
                email = :email, 
                password = :password, 
                employment = :employment, 
                position = :position
            WHERE id = :id
            SQL;
        $params = [
            ':id' => $employee->getId(),
            ':department_id' => $employee->getDepartmentId(),
            ':firstname' => $employee->getFirstName(),
            ':middlename' => $employee->getMiddleName(),
            ':lastname' => $employee->getLastName(),
            ':sex' => $employee->getSex(),
            ':birth_date' => $this->formatDateTimeOrNull($employee->getBirthDate()),
            ':experience' => $employee->getExperience(),
            ':address' => $employee->getAddress(),
            ':phone' => $employee->getPhone(),
            ':email' => $employee->getEmail(),
            ':password' => $employee->getPassword(),
            ':employment' => $this->formatDateTimeOrNull($employee->getEmployment()),
            ':position' => $employee->getPosition()
        ];

        $stmt = $this->connection->execute($query, $params);
        $f = $stmt->rowCount();
        if (!$f) {
            throw new RuntimeException("Optimistic lock failed for employee {$employee->getId()}");
        }
    }
}
