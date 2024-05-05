<?php

declare(strict_types=1);

namespace App\Domain\Employee;

use DateTimeImmutable;

class Employee
{
    /**
     * @param int|null $id
     * @param int $department_id
     * @param string $firstName
     * @param string $middleName
     * @param string|null $lastName
     * @param string $sex
     * @param DateTimeImmutable $birthDate
     * @param float|null $experience
     * @param string $address
     * @param string|null $phone
     * @param string|null $email
     * @param string|null $password
     * @param DateTimeImmutable $employment
     * @param string $position
     */
    public function __construct(
        private int $department_id,
        private string $firstName,
        private string $middleName,
        private string $sex,
        private DateTimeImmutable $birthDate,
        private string $address,
        private DateTimeImmutable $employment,
        private string $position,
        private ?int $id,
        private ?string $lastName = null,
        private ?float $experience = null,
        private ?string $phone = null,
        private ?string $email = null,
        private ?string $password = null,
    ) {
    }

    public function assignIdentifier(int $id): void
    {
        $this->id = $id;
    }

    public function edit(
        int $department_id,
        string $firstName,
        string $middleName,
        string $sex,
        DateTimeImmutable $birthDate,
        string $address,
        DateTimeImmutable $employment,
        string $position,
        ?int $id,
        ?string $lastName,
        ?float $experience,
        ?string $email,
        ?string $phone,
        ?string $password,
    ): void {
        $this->id = $id;
        $this->department_id = $department_id;
        $this->firstName = $firstName;
        $this->middleName = $middleName;
        $this->lastName = $lastName;
        $this->sex = $sex;
        $this->birthDate = $birthDate;
        $this->experience = $experience;
        $this->address = $address;
        $this->phone = $phone;
        $this->email = $email;
        $this->password = $password;
        $this->employment = $employment;
        $this->position = $position;
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getDepartmentId(): int
    {
        return $this->department_id;
    }

    public function getFirstName(): string
    {
        return $this->firstName;
    }

    public function getMiddleName(): string
    {
        return $this->middleName;
    }

    public function getLastName(): ?string
    {
        return $this->lastName;
    }

    public function getSex(): string
    {
        return $this->sex;
    }

    public function getBirthDate(): DateTimeImmutable
    {
        return $this->birthDate;
    }

    public function getExperience(): ?float
    {
        return $this->experience;
    }

    public function getAddress(): string
    {
        return $this->address;
    }

    public function getPhone(): ?string
    {
        return $this->phone;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function getPassword(): ?string
    {
        return $this->password;
    }

    public function setPassword(string $pass): void
    {
        $this->password = $pass;
    }

    public function setEmail(string $email): void
    {
        $this->email = $email;
    }

    public function getEmployment(): DateTimeImmutable
    {
        return $this->employment;
    }

    public function getPosition(): string
    {
        return $this->position;
    }
}
