<?php

declare(strict_types=1);

namespace App\Http\Controllers;

/**
 * Test controller for AI review demonstration.
 *
 * This controller is used for testing the AI code review workflow.
 *
 * @author aitednica-gif
 */
class TestController extends Controller
{
    /**
     * Return a test greeting message.
     *
     * @return string The greeting message
     */
    public function index(): string
    {
        return 'Hello from AI review';
    }
}
