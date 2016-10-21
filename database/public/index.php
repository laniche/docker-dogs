<?php 
try {
    $pdo = new PDO("mysql:host=database;dbname=docker_dev", 'root', 'docker');
    $stmt = $pdo->query('SELECT * FROM dockerlabs');
    $datas = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : null;

    echo '<pre>', print_r([
        'php_version' => phpversion(),
        'render_date' => new DateTime('now'),
        'pdo_datas' => $datas,
        $_SERVER
    ], true), '</pre>';
}
catch(PDOException $e) {
    header($_SERVER['SERVER_PROTOCOL'] . ' 500 Internal Server Error', true, 500);
    echo '<h1 style="color:red">Database Error</h1><p>', $e->getMessage(), '</p>', PHP_EOL;
}
catch(Exception $e) {
    header($_SERVER['SERVER_PROTOCOL'] . ' 500 Internal Server Error', true, 500);
    echo '<h1 style="color:red">Error</h1><p>', $e->getMessage(), '</p>', PHP_EOL;
}
