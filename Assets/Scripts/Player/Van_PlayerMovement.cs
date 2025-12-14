using UnityEngine;
using UnityEngine.InputSystem;

public class Van_PlayerMovement : MonoBehaviour
{
    [SerializeField] VirtualJoystick joystick;
    [SerializeField] float moveSpeed = 5f;
    [SerializeField] float rotationSpeed = 720f; // 旋轉速度（角度/秒）

    bool joystickActive;
    Vector2 movementInput;
    Rigidbody rb;
    Quaternion targetRotation;

    void Awake()
    {
        rb = GetComponent<Rigidbody>();
        targetRotation = transform.rotation;
    }
    //給 Input System 鍵盤/手把用的
    public void OnMove(InputValue value)
    {
        movementInput = value.Get<Vector2>();
        UpdateTargetRotation();
    }
    //給你自己程式用的
    public void SetMoveInput(Vector2 input)
    {
        movementInput = input;
        UpdateTargetRotation();
    }
    void Update()
    {
        //if (joystick == null) return;

        // 1) 搖桿正在被推
        if (joystick.InputVector.sqrMagnitude > 0.1f)
        {
            joystickActive = true;
            SetMoveInput(joystick.InputVector);
            return;
        }

        // 2) 搖桿剛剛放開：清零一次，讓角色停下來
        else if (joystickActive)
        {
            joystickActive = false;
            SetMoveInput(Vector2.zero);
        }
    }
    void FixedUpdate()
    {
        RotateAndMove();
    }
    //只是算出『要面向哪個方向』
    void UpdateTargetRotation()
    {
        // 有輸入才轉（避免抖動）
        if (movementInput.sqrMagnitude < 0.01f) return;
        // 將 2D 輸入轉成 3D 方向
        Vector3 dir = new Vector3(movementInput.x, 0f, movementInput.y);
        // 面向輸入方向
        targetRotation = Quaternion.LookRotation(dir, Vector3.up);
    }

    void RotateAndMove()
    {
        //慢慢轉過去的一個動作
        transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, rotationSpeed * Time.fixedDeltaTime);
        if (movementInput != Vector2.zero)//alway move forward
        {
            Vector3 move = transform.forward * moveSpeed * Time.fixedDeltaTime;
            rb.MovePosition(rb.position + move);

        }
        Debug.Log("這是transform.rotation" + transform.rotation);
    }



}
