<?php
function my_autoloader($class) {
    echo "Вызов функции автозагрузки<br>";
    include $class . ".php";
}

spl_autoload_register("my_autoloader");

$tom = new Person("Tom", 25);
$tom->printInfo();
?>
