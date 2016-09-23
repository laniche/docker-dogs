<?php
/**
 * index.php
 *
 * @author epagneul
 * @copyright  Copyright (c) 2016 Dogstudio.be
 * @since Jan 2016
 *
 * @package     docker
 * @subpackage
 */

$now = new DateTime();
echo '<pre>', print_r([
    $now->format('c'),
    $_SERVER
], true), '</pre>'; exit;


