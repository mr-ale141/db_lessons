<?php
class Person
{
    private $name, $age;
    function __construct($name, $age)
    {
        $this->name = $name;
        $this->age = $age;
    }
    function printInfo()
    {
        echo "Name: $this->name<br>Age: $this->age";
    }
}
?>
