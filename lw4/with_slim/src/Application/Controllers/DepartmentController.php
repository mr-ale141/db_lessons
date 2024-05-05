<?php

declare(strict_types=1);

namespace  App\Application\Controllers;

use App\Application\Controllers\Request\DepartmentRequestParser;
use App\Application\Controllers\Request\RequestValidationException;
use App\Domain\DomainException\DomainRecordNotFoundException;
use App\Domain\Service\ServiceProvider;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Slim\Views\Twig;
use Throwable;
use Twig\Error\LoaderError;
use Twig\Error\RuntimeError;
use Twig\Error\SyntaxError;

class DepartmentController
{
    private const HTTP_STATUS_OK = 200;
    private const HTTP_STATUS_BAD_REQUEST = 400;


    /**
     * @throws DomainRecordNotFoundException
     * @throws SyntaxError
     * @throws RuntimeError
     * @throws LoaderError
     */
    public function listDepartments(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $departmentList = ServiceProvider::getInstance()->getDepartmentService()->getDepartmentList();
        $view = Twig::fromRequest($request);

        $data = ['departmentList' => $departmentList];
        return $view->render($response, 'departments.twig', $data);
    }

    /**
     * @throws DomainRecordNotFoundException
     * @throws SyntaxError
     * @throws RuntimeError
     * @throws LoaderError
     */
    public function deleteDepartment(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        try {
            $id = DepartmentRequestParser::parseInteger($request->getQueryParams(), 'dep_id');
        } catch (RequestValidationException $exception) {
            return $this->badRequest($response, $exception->getFieldErrors());
        }
        ServiceProvider::getInstance()->getDepartmentService()->deleteDepartment($id);
        return $this->listDepartments($request, $response);
    }

    /**
     * @throws Throwable
     */
    public function createDepartment(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        try {
            $department = DepartmentRequestParser::parseDepartmentParams((array)$request->getParsedBody());
        } catch (RequestValidationException $exception) {
            return $this->badRequest($response, $exception->getFieldErrors());
        }

        $departmentId = ServiceProvider::getInstance()->getDepartmentService()->createDepartment($department);

        header('Location: http://127.0.0.1:8000/departments/');
        exit();
    }

    public function editDepartment(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        try {
            $department = DepartmentRequestParser::parseDepartmentParams((array)$request->getParsedBody());
            ServiceProvider::getInstance()->getDepartmentService()->editDepartment($department);
        } catch (RequestValidationException $exception) {
            return $this->badRequest($response, $exception->getFieldErrors());
        } catch (DomainRecordNotFoundException $exception) {
            return $this->badRequest($response, ['id' => $exception->getMessage()]);
        }

        return $this->success($response, []);
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
            throw new \RuntimeException($e->getMessage(), $e->getCode(), $e);
        }
    }
}
