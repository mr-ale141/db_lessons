<?php

declare(strict_types=1);

namespace App\Domain\Department;

class Department
{
    private ?int $id;
    private string $city;
    private string $address;
    private int $zipCode;
    private string $phone;
    private ?string $email;

    /**
     * @param int|null $id
     * @param string $city
     * @param string $address
     * @param int $zipCode
     * @param string $phone
     * @param string|null $email
     */
    public function __construct(
        string $city,
        string $address,
        int $zipCode,
        string $phone,
        ?string $email,
        ?int $id
    ) {
        $this->email = $email;
        $this->phone = $phone;
        $this->zipCode = $zipCode;
        $this->address = $address;
        $this->city = $city;
        $this->id = $id;
    }

    public function assignIdentifier(int $id): void
    {
        $this->id = $id;
    }

    /**
     * @param int $id
     * @param string $city
     * @param string $address
     * @param int $zipCode
     * @param string $phone
     * @param string|null $email
     * @return void
     */
    public function edit(
        int $id,
        string $city,
        string $address,
        int $zipCode,
        string $phone,
        ?string $email
    ): void {
        $this->id = $id;
        $this->city = $city;
        $this->address = $address;
        $this->zipCode = $zipCode;
        $this->phone = $phone;
        $this->email = $email;
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getCity(): string
    {
        return $this->city;
    }

    public function getAddress(): string
    {
        return $this->address;
    }

    public function getZipCode(): int
    {
        return $this->zipCode;
    }

    public function getPhone(): string
    {
        return $this->phone;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }
}
