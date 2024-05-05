<?php

declare(strict_types=1);

namespace App\Application\Controllers\Request;

use App\Application\Controllers\Request\RequestValidationException;
use App\Domain\Department\Department;

class DepartmentRequestParser
{
    private const MAX_TITLE_LENGTH = 200;

    public static function parseDepartmentParams(array $parameters): Department
    {
        return new Department(
            self::parseString($parameters, 'city', maxLength: self::MAX_TITLE_LENGTH),
            self::parseString($parameters, 'address', maxLength: self::MAX_TITLE_LENGTH),
            self::parseInteger($parameters, 'zip_code'),
            self::parseString($parameters, 'phone', maxLength: self::MAX_TITLE_LENGTH),
            self::parseString($parameters, 'email', maxLength: self::MAX_TITLE_LENGTH),
            self::parseInteger($parameters, 'dep_id'),
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

    public static function parseString(array $parameters, string $name, ?int $maxLength = null): ?string
    {
        $value = $parameters[$name] ?? null;
        if (is_string($value)) {
            return $value;
        }
        if ($maxLength !== null && mb_strlen($value) > $maxLength) {
            throw new RequestValidationException([$name => "String value too long (exceeds $maxLength characters)"]);
        }
        return null;
    }

    private static function isIntegerValue(mixed $value): bool
    {
        return is_numeric($value) && (is_int($value) || ctype_digit($value));
    }
}
