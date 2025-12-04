using UnityEngine;

public class RotateOnDrag : MonoBehaviour
{
    public float rotateSpeed = 0.3f;

    bool dragging;
    Vector3 lastMousePos;//這是滑鼠的

    void Update()
    {
        // 按下滑鼠左鍵開始拖曳
        if (Input.GetMouseButtonDown(0))
        {
            dragging = true;
            lastMousePos = Input.mousePosition;//開始拖曳的瞬間，滑鼠在螢幕上的座標位置
        }

        // 放開滑鼠左鍵停止
        if (Input.GetMouseButtonUp(0))
        {
            dragging = false;
        }

        if (dragging)
        {
            //計算滑鼠的移動量滑鼠，只會左右移動X軸
            //為了Input.mousePosition是vector3 所以都用vector3
            Vector3 delta = Input.mousePosition - lastMousePos;
            // 計算每一幀的旋轉量
            float rotateAmount = -delta.x * rotateSpeed;
            float currentY = transform.eulerAngles.y;
            // 把 0~360 轉成 -180~180，避免跳值
            if (currentY > 180f) currentY -= 360f;
            //這是總量的角度
            float newY = currentY + rotateAmount;
            newY = Mathf.Clamp(newY, -20f, 66f);

            transform.rotation = Quaternion.Euler(0f, newY, 0f);

            //把本幀的滑鼠位置，記起來給下一幀比較用
            lastMousePos = Input.mousePosition;
        }

    }
}
