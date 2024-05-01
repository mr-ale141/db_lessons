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
        private ?int $id,
        private int $department_id,
        private string $firstName,
        private string $middleName,
        private ?string $lastName = null,
        private string $sex,
        private DateTimeImmutable $birthDate,
        private ?float $experience = null,
        private string $address,
        private ?string $phone = null,
        private ?string $email = null,
        private ?string $password = null,
        private DateTimeImmutable $employment,
        private string $position
    ) {
    }

    public function assignIdentifier(int $id): void
    {
        $this->id = $id;
    }

    public function edit(
        ?int $id,
        int $department_id,
        string $firstName,
        string $middleName,
        ?string $lastName,
        string $sex,
        DateTimeImmutable $birthDate,
        ?float $experience,
        string $address,
        ?string $phone,
        ?string $email,
        ?string $password,
        DateTimeImmutable $employment,
        string $position
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

    public function getEmployment(): DateTimeImmutable
    {
        return $this->employment;
    }

    public function getPosition(): string
    {
        return $this->position;
    }
}
