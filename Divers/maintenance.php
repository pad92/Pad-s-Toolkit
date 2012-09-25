<?php

// Redirection Apache :
// RewriteEngine on
// RewriteCond %{REQUEST_URI} !/maintenance.html$
// RewriteRule $ /maintenance.html [R=302,L]

?>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Serveur en maintenance</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="generator" content="vim">
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
        <!-- Le styles -->
        <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.0.4/css/bootstrap.css" rel="stylesheet">
        <style>
            body {
                padding-top: 60px; /* 60px to make the container go all the way to the bottom of the topbar */
            }
        </style>
        <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.0.4/css/bootstrap-responsive.css" rel="stylesheet">
        <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
        <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
    </head>
    <body>
        <div class="container">
            <div class="page-header">
                <h1 class="pagination-centered">Serveur en maintenance</h1>
            </div>
            <div class="alert alert-error pagination-centered">
                <i class="icon-warning-sign"></i>
                Toutes nos escuses, <?php echo  $_SERVER['SERVER_NAME']; ?> est actuelement en maintenance pour quelque minutes.
                <i class="icon-warning-sign"></i>
            </div>
        </div>
        <footer class="container pagination-centered">
        </footer>
        <script src="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.0.4/js/bootstrap.min.js"></script>
    </body>
</html>
