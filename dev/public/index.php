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
echo '<pre>', $now->format('c'), '</pre>', PHP_EOL;
