using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [SerializeField] float moveSpeed = 5f;
    [SerializeField] float xClamp = 3f;//限制左右的範圍
    [SerializeField] float zClamp = 3f;

    Vector2 movement;
    Rigidbody rigidBody;

    void Awake()//在物件啟用時最先執行，通常用來初始化變數
    {
        rigidBody = GetComponent<Rigidbody>();
    }
    void FixedUpdate()
    {
        HandleMovement();
    }
    public void Move(InputAction.CallbackContext context)
    {
        movement = context.ReadValue<Vector2>();//從玩家輸入中讀取一個「方向向量」用來表示「我要往哪裡走」
    }
    void HandleMovement()
    {
        Vector3 currentPosition = rigidBody.position;
        Vector3 moveDirection = new Vector3(movement.x, 0f, movement.y); //把 2D 的輸入轉成 3D 的方向向量
        Vector3 newPosition = currentPosition + moveDirection * (moveSpeed * Time.fixedDeltaTime);

        newPosition.x = Mathf.Clamp(newPosition.x, -xClamp, xClamp);//會強制把 value 限制在 min ~ max 之間。
        newPosition.z = Mathf.Clamp(newPosition.z, -zClamp, zClamp);
        rigidBody.MovePosition(newPosition);
    }
}