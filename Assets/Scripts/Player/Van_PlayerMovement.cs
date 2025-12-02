using UnityEngine;
using UnityEngine.InputSystem;

public class Van_PlayerMovement : MonoBehaviour
{
    [SerializeField] float moveSpeed = 5f;
    [SerializeField] float rotationSpeed = 720f; // 旋轉速度（角度/秒）

    Vector2 movementInput;
    Rigidbody rb;
    Quaternion targetRotation;

    void Awake()
    {
        rb = GetComponent<Rigidbody>();
        targetRotation = transform.rotation;
    }

    public void OnMove(InputValue value)
    {
        movementInput = value.Get<Vector2>();
        UpdateTargetRotation();
    }

    void FixedUpdate()
    {
        RotateAndMove();
    }

    void UpdateTargetRotation()
    {
        // 根據輸入改變目標朝向
        if (movementInput == Vector2.up)
            targetRotation = Quaternion.Euler(0f, 0f, 0f);
        else if (movementInput == Vector2.right)
            targetRotation = Quaternion.Euler(0f, 90f, 0f);
        else if (movementInput == Vector2.left)
            targetRotation = Quaternion.Euler(0f, -90f, 0f);
        else if (movementInput == Vector2.down)
            targetRotation = Quaternion.Euler(0f, 180f, 0f);
    }

    void RotateAndMove()
    {
        transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, rotationSpeed * Time.fixedDeltaTime);
        if (movementInput != Vector2.zero)//alway move forward
        {
            Vector3 move = transform.forward * moveSpeed * Time.fixedDeltaTime;
            rb.MovePosition(rb.position + move);
        }
    }


}
