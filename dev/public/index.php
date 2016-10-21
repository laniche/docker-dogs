<?php
try {
    switch (trim(addslashes($_SERVER['REQUEST_URI']))) {
        case '/pass':
            header($_SERVER['SERVER_PROTOCOL'] . ' 200 OK', true, 200);
            echo 'success'; exit;
        case '/wrong':
            header($_SERVER['SERVER_PROTOCOL'] . ' 500 Internal Server Error', true, 500);
            echo 'error'; exit;
        case '/info':
            header($_SERVER['SERVER_PROTOCOL'] . ' 200 OK', true, 200);
            phpinfo();
        default:
            header($_SERVER['SERVER_PROTOCOL'] . ' 200 OK', true, 200);
            header('Content-Type:text/text; charset=UTF-8');
            var_export($_SERVER);
    }
}
catch(Exception $e) {
    header($_SERVER['SERVER_PROTOCOL'] . ' 500 Internal Server Error', true, 500);
    echo '<h1 style="color:red">Error</h1><p>', $e->getMessage(), '</p>', PHP_EOL;
}
