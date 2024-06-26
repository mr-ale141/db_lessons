<?php

declare(strict_types=1);

namespace App\Application\Middleware;

use App\Domain\Service\ServiceProvider;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\MiddlewareInterface as Middleware;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;

class SessionMiddleware implements Middleware
{
    /**
     * {@inheritdoc}
     */
    public function process(Request $request, RequestHandler $handler): Response
    {
        $cookie = $request->getCookieParams();

        $emailFromCookie = $cookie['email'] ?? '';
        $authFromCookie = $cookie['auth'] ?? '';

        $serviceProvider = ServiceProvider::getInstance();
        $employeeService = $serviceProvider->getEmployeeService();
        $employee = $employeeService->getEmployeeByEmail($emailFromCookie);

        if ($employee !== null && $employee->getPassword() !== null) {
            $hash = hash(
                'md5',
                $employee->getEmail() .
                $employee->getPassword()
            );
            if ($authFromCookie === $hash) {
                if ($request->getUri()->getPath() === '/login') {
                    // если авторизован то на страницу авторизации не заходим
                    header('Location: http://127.0.0.1:8000/departments/');
                    exit();
                }
                // или разрешаем любой путь
                return $handler->handle($request);
            }
        }
        // если не авторизован
        if ($request->getUri()->getPath() === '/login') {
            return $handler->handle($request);
        }
        // withHeader (location) and statusCode 303
        header('Location: http://127.0.0.1:8000/login');
        exit();
    }
}
