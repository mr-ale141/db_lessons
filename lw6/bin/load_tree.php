#!/usr/bin/env php
<?php
declare(strict_types=1);

require_once(__DIR__ . '/../vendor/autoload.php');

use App\Common\Database\ConnectionProvider;
use App\TreeOfLife\LOader\TreeOfLifeLoader;
use App\TreeOfLife\Model\TreeOfLifeNode;
use App\TreeOfLife\Service\ClosureTableTreeService;

const DATA_DIR = __DIR__ . '/../data';

function loadTreeOfLife(string $nodesCsvPath, string $linksCsvPath): TreeOfLifeNode
{
    $loader = new TreeOfLifeLoader();
    $loader->loadNodesCsv($nodesCsvPath);
    $loader->loadLinksCsv($linksCsvPath);
    return $loader->getTreeRoot();
}

$root = loadTreeOfLife(DATA_DIR . '/treeoflife_nodes.csv', DATA_DIR . '/treeoflife_links.csv');
echo "Root node: {$root->getId()} '{$root->getName()}'";

$connection = ConnectionProvider::getConnection();
$service = new ClosureTableTreeService($connection);
$service->saveTree($root);
