<?php

declare(strict_types=1);

namespace App\Application\Controllers\Request;

use App\Application\Controllers\Request\RequestValidationException;
use App\Domain\Employee\Employee;
use DateTimeImmutable;

class EmployeeRequestParser
{
    private const MAX_TITLE_LENGTH = 200;

    public static function parseEmployeeParams(array $parameters): Employee
    {
        return new Employee(
            self::parseInteger($parameters, 'dep_id'),
            self::parseString($parameters, 'fname', maxLength: self::MAX_TITLE_LENGTH),
            self::parseString($parameters, 'mname', maxLength: self::MAX_TITLE_LENGTH),
            self::parseString($parameters, 'sex', maxLength: self::MAX_TITLE_LENGTH),
            self::parseDate($parameters, 'birth'),
            self::parseString($parameters, 'address', maxLength: self::MAX_TITLE_LENGTH),
            self::parseDate($parameters, 'employment'),
            self::parseString($parameters, 'position', maxLength: self::MAX_TITLE_LENGTH),
            self::parseInteger($parameters, 'emp_id'),
            self::parseString($parameters, 'lname', maxLength: self::MAX_TITLE_LENGTH),
            self::parseFloat($parameters, 'exp'),
            self::parseString($parameters, 'phone', maxLength: self::MAX_TITLE_LENGTH),
            null,
            null,
        );
    }

    public static function parseInteger(array $parameters, string $name): ?int
    {
        $value = $parameters[$name] ?? null;
        if (self::isIntegerValue($value)) {
            return (int)$value;
        }
        return null;
    }

    public static function parseFloat(array $parameters, string $name): ?float
    {
        $value = $parameters[$name] ?? null;
        if (self::isFloatValue($value)) {
            return (float)$value;
        }
        return null;
    }

    public static function parseDate(array $parameters, string $name): ?DateTimeImmutable
    {
        $value = $parameters[$name] ?? null;
        try {
            $date = new DateTimeImmutable($value);
        } catch (\Exception $e) {
            throw new RequestValidationException([$name => 'Invalid date value']);
        }
        return $date;
    }

    public static function parseString(array $parameters, string $name, ?int $maxLength = null): string
    {
        $value = $parameters[$name] ?? null;
        if (!is_string($value)) {
            throw new RequestValidationException([$name => 'Invalid string value']);
        }
        if ($maxLength !== null && mb_strlen($value) > $maxLength) {
            throw new RequestValidationException([$name => "String value too long (exceeds $maxLength characters)"]);
        }
        return $value;
    }

    private static function isIntegerValue(mixed $value): bool
    {
        return is_numeric($value) && (is_int($value) || ctype_digit($value));
    }

    private static function isFloatValue(mixed $value): bool
    {
        return is_numeric($value) && (is_float($value) || ctype_digit($value));
    }
}
