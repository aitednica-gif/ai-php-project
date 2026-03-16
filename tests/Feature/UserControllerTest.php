<?php

declare(strict_types=1);

namespace Tests\Feature;

use Tests\TestCase;

class UserControllerTest extends TestCase
{
    /**
     * Test que la ruta /users responde correctamente.
     */
    public function test_users_index_returns_json(): void
    {
        $response = $this->getJson('/api/users');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'users',
                'message',
            ]);
    }

    /**
     * Test que la ruta /users/{id} responde correctamente.
     */
    public function test_user_show_returns_json(): void
    {
        $response = $this->getJson('/api/users/1');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'user' => [
                    'id',
                    'name',
                    'email',
                ],
            ]);
    }

    /**
     * Test validación de creación de usuario.
     */
    public function test_user_store_validates_request(): void
    {
        $response = $this->postJson('/api/users', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name', 'email', 'password']);
    }

    /**
     * Test que no se puede crear usuario con email duplicado.
     */
    public function test_user_store_requires_unique_email(): void
    {
        $response = $this->postJson('/api/users', [
            'name' => 'Test User',
            'email' => 'test@test.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(201);
    }

    /**
     * Test que la actualización de usuario funciona.
     */
    public function test_user_update_returns_json(): void
    {
        $response = $this->putJson('/api/users/1', [
            'name' => 'Nuevo nombre',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Usuario actualizado exitosamente',
            ]);
    }

    /**
     * Test que la eliminación de usuario funciona.
     */
    public function test_user_destroy_returns_json(): void
    {
        $response = $this->deleteJson('/api/users/1');

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Usuario 1 eliminado exitosamente',
            ]);
    }
}
