<?php
$name = "не определено";
$age = "не определен";
if(isset($_POST["name"])){

    $name = $_POST["name"];
}
if(isset($_POST["age"])){

    $age = $_POST["age"];
}
echo "Имя: $name </br> Возраст: $age";
?>
</br>
</br>
<?php
$name = "не определено";
$age = "не определен";
if(isset($_POST["name"])){

$name = htmlentities($_POST["name"]);
}
if(isset($_POST["age"])){

$age = htmlentities($_POST["age"]);
}
echo "Имя: $name </br> Возраст: $age";
?>
</br>
</br>
<?php
$name = "не определено";
$age = "не определен";
if(isset($_POST["name"])){

    $name = htmlspecialchars($_POST["name"]);
}
if(isset($_POST["age"])){

    $age = htmlspecialchars($_POST["age"]);
}
echo "Имя: $name </br> Возраст: $age";
?>
</br>
</br>
<?php
$name = "не определено";
$age = "не определен";
if(isset($_POST["name"])){

    $name = strip_tags($_POST["name"]);
}
if(isset($_POST["age"])){

    $age = strip_tags($_POST["age"]);
}
echo "Имя: $name </br> Возраст: $age";
?>

