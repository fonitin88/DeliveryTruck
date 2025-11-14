using Unity.Mathematics;
using UnityEngine;
using UnityEngine.InputSystem;

public class Playermovement : MonoBehaviour
{
    [SerializeField] float controlSpeed = 10f;
    [SerializeField] float xClampRange = 5f;//限制X軸移動多少
    [SerializeField] float yClampRange = 5f;//限制y軸移動多少

    [SerializeField] float controlRollFactor = 30f;
    [SerializeField] float controlPitchFactor = 30f;
    [SerializeField] float rotationSpeed = 5f;

    Vector2 movement;
    void Update()
    {
        ProcessTranslation();
        ProcessRotation();
    }
    public void OnMove(InputValue value)//一定要On+在input上設定的英文
    {
        movement = (value.Get<Vector2>());
        //Get<Vector2>() 常用於 2D / 平面方向控制
    }
    void ProcessTranslation()
    {
        float xOffset = movement.x * controlSpeed * Time.deltaTime;
        float rawXPos = transform.localPosition.x + xOffset;
        float clampedXPos = Mathf.Clamp(rawXPos, -xClampRange, xClampRange);

        float yOffset = movement.y * controlSpeed * Time.deltaTime;
        float rawYPos = transform.localPosition.y + yOffset;
        float clampedYPos = Mathf.Clamp(rawYPos, -yClampRange, yClampRange);

        transform.localPosition = new Vector3(clampedXPos, clampedYPos, 0f);
    }
    void ProcessRotation()
    {
        float pitch = -controlPitchFactor * movement.y;
        float roll = -controlRollFactor * movement.x;
        Quaternion targetRotaion = Quaternion.Euler(pitch, 0f, roll);
        transform.localRotation = Quaternion.Lerp(transform.localRotation, targetRotaion, rotationSpeed * Time.deltaTime);
    }
}
