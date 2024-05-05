<?php

declare(strict_types=1);

namespace  App\Application\Controllers;

use App\Application\Controllers\Request\EmployeeRequestParser;
use App\Application\Controllers\Request\RequestValidationException;
use App\Domain\DomainException\DomainRecordNotFoundException;
use App\Domain\Service\ServiceProvider;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use RuntimeException;
use Slim\Views\Twig;
use Twig\Error\LoaderError;
use Twig\Error\RuntimeError;
use Twig\Error\SyntaxError;

class EmployeeController
{
    private const HTTP_STATUS_OK = 200;
    private const HTTP_STATUS_BAD_REQUEST = 400;

    /**
     * @throws SyntaxError
     * @throws RuntimeError
     * @throws LoaderError
     */
    public function listEmployees(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        try {
            $id = EmployeeRequestParser::parseInteger($request->getQueryParams(), 'dep_id');
            $department = ServiceProvider::getInstance()->getDepartmentService()->getDepartment($id);
        } catch (RequestValidationException $exception) {
            return $this->badRequest($response, $exception->getFieldErrors());
        } catch (DomainRecordNotFoundException $exception) {
            return $this->badRequest($response, ['id' => $exception->getMessage()]);
        }
        $employees = ServiceProvider::getInstance()->getEmployeeService()->getEmployeesByDepartmentId($id);
        $view = Twig::fromRequest($request);
        $data['department'] = $department;
        $data['employeeList'] = $employees;
        return $view->render($response, 'employees.twig', $data);
    }

    /**
     * @throws SyntaxError
     * @throws RuntimeError
     * @throws LoaderError
     * @throws DomainRecordNotFoundException
     */
    public function deleteEmployee(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        try {
            $id = EmployeeRequestParser::parseInteger($request->getQueryParams(), 'emp_id');
        } catch (RequestValidationException $exception) {
            return $this->badRequest($response, $exception->getFieldErrors());
        }
        $department_id = ServiceProvider::getInstance()->getEmployeeService()->getEmployee($id)->getDepartmentId();
        ServiceProvider::getInstance()->getEmployeeService()->deleteEmployee($id);
        header('Location: http://127.0.0.1:8000/edit_dep/?dep_id=' . $department_id);
        exit();
    }

    /**
     * @throws \Throwable
     */
    public function createEmployee(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        try {
            $employee = EmployeeRequestParser::parseEmployeeParams((array)$request->getParsedBody());
        } catch (RequestValidationException $exception) {
            return $this->badRequest($response, $exception->getFieldErrors());
        }

        $employeeId = ServiceProvider::getInstance()->getEmployeeService()->createEmployee($employee);

        header('Location: http://127.0.0.1:8000/edit_dep/?dep_id=' . $employee->getDepartmentId());
        exit();
    }

    /**
     * @throws DomainRecordNotFoundException
     * @throws \Throwable
     */
    public function saveNewPassword(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $service = ServiceProvider::getInstance()->getEmployeeService();
        $json = json_decode($request->getBody()->getContents(), true);
        try {
            $employee = $service->getEmployee((int)$json['id']);
        } catch (DomainRecordNotFoundException $exception) {
            return $this->badRequest($response, ['id' => $exception->getMessage()]);
        }
        $employee->setEmail($json['email']);
        $employee->setPassword($json['pass']);

        $service->editEmployee($employee);

        return $this->success($response, []);
    }

    public function editEmployee(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        try {
            $employee = EmployeeRequestParser::parseEmployeeParams((array)$request->getParsedBody());
            ServiceProvider::getInstance()->getEmployeeService()->editEmployee($employee);
        } catch (RequestValidationException $exception) {
            return $this->badRequest($response, $exception->getFieldErrors());
        } catch (DomainRecordNotFoundException $exception) {
            return $this->badRequest($response, ['id' => $exception->getMessage()]);
        } catch (\Throwable $e) {
            throw new RuntimeException($e->getMessage(), $e->getCode(), $e);
        }

        header('Location: http://127.0.0.1:8000/edit_dep/?dep_id=' . $employee->getDepartmentId());
        exit();
    }

    private function success(ResponseInterface $response, array $responseData): ResponseInterface
    {
        return $this->withJson($response, $responseData)->withStatus(self::HTTP_STATUS_OK);
    }

    private function badRequest(ResponseInterface $response, array $errors): ResponseInterface
    {
        $responseData = ['errors' => $errors];
        return $this->withJson($response, $responseData)->withStatus(self::HTTP_STATUS_BAD_REQUEST);
    }

    private function withJson(ResponseInterface $response, array $responseData): ResponseInterface
    {
        try {
            $responseBytes = json_encode($responseData, JSON_THROW_ON_ERROR);
            $response->getBody()->write($responseBytes);
            return $response->withHeader('Content-Type', 'application/json');
        } catch (\JsonException $e) {
            throw new RuntimeException($e->getMessage(), $e->getCode(), $e);
        }
    }
}
