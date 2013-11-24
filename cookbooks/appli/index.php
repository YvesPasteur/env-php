<?php
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

if (file_exists('/var/www/xhgui/external/header.php')) {
    require_once '/var/www/xhgui/external/header.php';
}
require_once __DIR__.'/vendor/autoload.php';

$app = new Silex\Application();
$app['debug'] = true;


$dbh = new PDO('mysql:host=localhost;dbname=test');

$app->get('/', function () use ($dbh) {
    $output = '<h1>Hello !</h1>';

    $output .= '<form action="/" method="POST">
        <input type="text" value="" name="message"/>
        <input type="submit"/>
    </form>';

    $res = $dbh->query('SELECT * FROM message');
    $output .= '<ul>';
    foreach ($res as $row) {
        $output .= '<li>' . $row['text'] . '</li>';
    }
    $output .= '</ul>';
    return $output;
});

$app->post('/', function (Request $request) use ($dbh, $app) {
    $message = $request->get('message');

    $stmt = $dbh->prepare('INSERT INTO message VALUES (:msg)');
    $stmt->bindParam(':msg', $message, PDO::PARAM_STR, 120);
    if (! $stmt->execute()) {
        return "Erreur à l'insertion !";
    }

    return $app->redirect('/');
});


$app->run();
