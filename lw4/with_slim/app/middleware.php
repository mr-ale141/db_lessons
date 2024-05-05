<?php

declare(strict_types=1);

use App\Application\Middleware\SessionMiddleware;
use Slim\App;
use Slim\Views\Twig;
use Slim\Views\TwigMiddleware;

return function (App $app) {
    $app->add(SessionMiddleware::class);

    $twig = Twig::create(__DIR__ . '\..\src\Application\Templates', ['cache' => false]);
    $app->add(TwigMiddleware::create($app, $twig));
};
