<?php
// filepath: c:\Users\Amrit Joshi\OneDrive\Desktop\LinuxPro\loginator-3000\router.php
// Router to handle bash script execution for the LinuxPro system


// Function to execute bash scripts and handle their output
function executeBashScript($scriptPath, $postData = '') {
    // Debug
    error_log("Executing script: $scriptPath");
    
    // Make sure the script exists
    if (!file_exists($scriptPath)) {
        header("HTTP/1.0 404 Not Found");
        echo "Script not found: $scriptPath";
        return false;
    }

    // Make the script executable
    chmod($scriptPath, 0755);

    // Set up environment variables like CGI would
    $descriptorspec = [
        0 => ["pipe", "r"],  // stdin
        1 => ["pipe", "w"],  // stdout
        2 => ["pipe", "w"]   // stderr
    ];

    // Set up proper environment variables
    $env = $_SERVER;
    $env['CONTENT_LENGTH'] = strlen($postData);
    $env['REQUEST_METHOD'] = $_SERVER['REQUEST_METHOD'];
    $env['SCRIPT_FILENAME'] = $scriptPath;
    
    // Pass cookies from browser to script
    if (isset($_SERVER['HTTP_COOKIE'])) {
        $env['HTTP_COOKIE'] = $_SERVER['HTTP_COOKIE'];
        error_log("Passing cookie to script: " . $_SERVER['HTTP_COOKIE']);
    }

    // Execute the script with proper escaping
    $escapedPath = escapeshellarg($scriptPath);
    $process = proc_open("bash $escapedPath", $descriptorspec, $pipes, dirname($scriptPath), $env);

    if (is_resource($process)) {
        // Write POST data to stdin if applicable
        if (!empty($postData)) {
            fwrite($pipes[0], $postData);
            fclose($pipes[0]);
        } else {
            fclose($pipes[0]);
        }

        // Read output
        $output = stream_get_contents($pipes[1]);
        $error = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);

        // Close the process
        proc_close($process);

        // Log errors for debugging
        if ($error) {
            error_log("Script error: $error");
        }

        // CRITICAL: Process headers and body properly
        // Split output into headers and body on blank line
        $parts = explode("\r\n\r\n", $output, 2);
        if (count($parts) < 2) {
            $parts = explode("\n\n", $output, 2);
        }
        
        if (count($parts) > 1) {
            // We have headers and body
            $headers = $parts[0];
            $body = $parts[1];
            
            // Set each header line individually
            foreach (explode("\n", $headers) as $header) {
                $header = trim($header);
                if (!empty($header)) {
                    error_log("Setting header: $header");
                    header($header);
                }
            }
            
            echo $body;
        } else {
            // No headers separator found, just output everything
            echo $output;
        }
        
        return true;
    }
    
    return false;
}

// Main router code
$uri = $_SERVER['REQUEST_URI'];

// Handle bash scripts in /bin/
if (strpos($uri, '/bin/') === 0 && substr($uri, -3) === '.sh') {
    // Get the full script path
    $scriptPath = __DIR__ . $uri;
    
    error_log("Router handling script request: $scriptPath");
    
    // Get POST data
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $postData = file_get_contents('php://input');
        if (empty($postData) && !empty($_POST)) {
            // If raw input is empty, build from $_POST
            $postPairs = [];
            foreach ($_POST as $key => $value) {
                $postPairs[] = urlencode($key) . '=' . urlencode($value);
            }
            $postData = implode('&', $postPairs);
        }
        error_log("Using POST data: $postData");
    } else {
        $postData = '';
    }
    
    // Execute the script
    executeBashScript($scriptPath, $postData);
    exit;
}

// For HTML and other static files, serve as normal
return false;
?>