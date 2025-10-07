<?php
$data = [
    "name" => "Test Registration",
    "username" => "test_reg_123",
    "email" => "testreg123@example.com", 
    "contact_number" => "+1234567890",
    "gender" => "male",
    "password" => "password123",
    "password_confirmation" => "password123"
];

$options = [
    "http" => [
        "header" => "Content-Type: application/json\r\nAccept: application/json\r\n",
        "method" => "POST",
        "content" => json_encode($data)
    ]
];

$context = stream_context_create($options);
$result = file_get_contents("http://127.0.0.1:8000/api/register", false, $context);

if ($result !== FALSE) {
    echo "Registration API Response:" . PHP_EOL;
    echo $result . PHP_EOL;
} else {
    echo "Registration API failed" . PHP_EOL;
}
?>
