<?php

declare(strict_types=1);

use App\Application\Controllers\DepartmentController;
use App\Application\Controllers\EmployeeController;
use App\Domain\Service\ServiceProvider;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
//use Slim\Interfaces\RouteCollectorProxyInterface as Group;
use Slim\App;
use Slim\Views\Twig;

return function (App $app) {
    $app->options('/{routes:.*}', function (Request $request, Response $response) {
        // CORS Pre-Flight OPTIONS Request Handler
        return $response;
    });
    $app->get('/login', function (Request $request, Response $response) {
        $view = Twig::fromRequest($request);
        return $view->render($response, 'login.twig');
    });
    $app->get('/', function (Request $request, Response $response) {
        header('Location: http://127.0.0.1:8000/departments/');
        exit();
    });
    $app->get('/departments/', DepartmentController::class . ':listDepartments');

    $app->get('/add_dep/', function (Request $request, Response $response) {
        $view = Twig::fromRequest($request);
        return $view->render($response, 'add_dep.twig');
    });
    $app->post('/add_dep/', DepartmentController::class . ':createDepartment');
    $app->get('/delete_dep/', DepartmentController::class . ':deleteDepartment');

    $app->get('/edit_dep/', EmployeeController::class . ':listEmployees');
    $app->get('/delete_emp/', EmployeeController::class . ':deleteEmployee');
    $app->get('/add_emp/', function (Request $request, Response $response) {
        $id = $request->getQueryParams()['dep_id'];
        $view = Twig::fromRequest($request);
        return $view->render($response, 'add_emp.twig', ['isEdit' => false, 'dep_id' => $id]);
    });
    $app->post('/add_emp/', EmployeeController::class . ':createEmployee');
    $app->post('/edit_emp/', EmployeeController::class . ':editEmployee');
    $app->get('/edit_emp/', function (Request $request, Response $response) {
        $id = $request->getQueryParams()['emp_id'];
        $employee = ServiceProvider::getInstance()->getEmployeeService()->getEmployee((int)$id);
        $view = Twig::fromRequest($request);
        return $view->render($response, 'add_emp.twig', ['isEdit' => true, 'employee' => $employee]);
    });
    $app->post('/save_pass/', EmployeeController::class . ':saveNewPassword');
};
