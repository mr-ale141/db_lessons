<?php
echo("Hello</br>");

$input = "This is the end";
$search = "is";
$position = strpos($input, $search); // 2
if($position!==false)
{
    echo "Позиция подстроки '$search' в строке '$input': $position</br>";
}

$position = strrpos($input, $search);
if($position!==false)
{
    echo "Позиция подстроки '$search' в строке '$input': $position</br>";
}

$input = "Мама мыла раму";
$search = "мы";
$position = strpos($input, $search); // 9

if($position!==false)
{
    echo "Позиция подстроки '$search' в строке '$input': $position</br>";
}

$position = mb_strpos($input, $search); // 5

if($position!==false)
{
    echo "Позиция подстроки '$search' в строке '$input': $position</br>";
}

$input = "  Мама мыла раму  ";
$input = trim($input);
echo($input . "</br>");

$input = "Мама мыла раму";
$num = mb_strlen($input);
echo "<br>";
echo $num;
echo "<br>";

$input = "The world is mine!";
$subinput1 = substr($input, 2);
$subinput2 = substr($input, 2, 6);
echo $subinput1;
echo "<br>";
echo $subinput2;

$input = "Мама мыла раму";
$input = str_replace("мы", "ши", $input);
echo "<br>";
echo $input;

echo(strlen("Текст"));

phpinfo();