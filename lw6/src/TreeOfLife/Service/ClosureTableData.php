<?php
declare(strict_types=1);

namespace App\TreeOfLife\Service;

class ClosureTableData
{
    private int $nodeId;
    private int $ancestorId;
    private int $distance;
    private bool $isRoot;

    public function __construct(int $nodeId, int $ancestorId, int $distance, bool $isRoot)
    {
        $this->nodeId = $nodeId;
        $this->ancestorId = $ancestorId;
        $this->distance = $distance;
        $this->isRoot = $isRoot;
    }

    public function getNodeId(): int
    {
        return $this->nodeId;
    }

    public function getAncestorId(): int
    {
        return $this->ancestorId;
    }

    public function getDistance(): int
    {
        return $this->distance;
    }

    public function isRoot(): bool
    {
        return $this->isRoot;
    }
}
