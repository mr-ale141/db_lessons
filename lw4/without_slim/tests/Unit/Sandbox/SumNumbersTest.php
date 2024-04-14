<?php
declare(strict_types=1);

namespace App\Tests\Unit\Sandbox;

use PHPUnit\Framework\TestCase;

class SumNumbersTest extends TestCase
{
    public function testUploadPaths()
    {
        $this->assertEquals(4, 2 + 2);
    }
}