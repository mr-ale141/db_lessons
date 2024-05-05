<?php

declare(strict_types=1);

namespace App\Domain\Department;

class DepartmentListRow
{
    private int $id;
    private string $city;
    private string $address;
    private int $zipCode;
    private string $phone;
    private int $size;
    private ?string $email;

    public function __construct(
        int $ig,
        string $city,
        string $address,
        int $zipCode,
        string $phone,
        int $size,
        ?string $email
    ) {
        $this->id = $ig;
        $this->city = $city;
        $this->address = $address;
        $this->zipCode = $zipCode;
        $this->phone = $phone;
        $this->size = $size;
        $this->email = $email;
    }

    public function getId(): int
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

    public function getSize(): int
    {
        return $this->size;
    }

    public function getEmail(): string
    {
        return $this->email;
    }
}
