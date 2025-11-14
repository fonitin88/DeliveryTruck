using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerWeapon : MonoBehaviour
{
    [SerializeField] GameObject[] lasers; //發射的特效
    [SerializeField] RectTransform crosshair;//瞄準的UI（視覺指標）
    [SerializeField] Transform targetPoint;//武器或雷射要朝哪個方向發射
    [SerializeField] float targetDistance = 50f;

    bool isFiring = false;

    void Start()
    {
        //Cursor.visible = false;//隱藏螢幕鼠標
    }

    void Update()
    {
        ProcessFiring();
        MoveCrosshair();
        MoveTargetPoint();
        AimLasers();
    }
    public void OnFire(InputValue value)// 使用 Input System 綁定的 Fire 行為
    {
        isFiring = value.isPressed;//按下去就會控制emissionModule.enabled
    }
    void ProcessFiring() //讓雷射看起來有或沒有發射而已，但不改變雷射的方向。
    {
        foreach (GameObject laser in lasers)
        {
            var emissionModule = laser.GetComponent<ParticleSystem>().emission;
            emissionModule.enabled = isFiring;
        }
    }
    void MoveCrosshair()
    {
        crosshair.position = Input.mousePosition; //圖片跟著滑鼠
    }

    void MoveTargetPoint() //讓目標點跟著滑鼠動
    {
        Vector3 targetPointPosition = new Vector3(Input.mousePosition.x, Input.mousePosition.y, targetDistance);
        targetPoint.position = Camera.main.ScreenToWorldPoint(targetPointPosition);
    }
    void AimLasers()//控制雷射朝哪個方向開火
    {
        foreach (GameObject laser in lasers)
        {
            Vector3 fireDirection = targetPoint.position - this.transform.position;//先算出要去目標物的角度
            Quaternion rotationToTarget = Quaternion.LookRotation(fireDirection);//讓雷射轉向這個角度
            laser.transform.rotation = rotationToTarget;//雷射朝那個方向轉過去
        }
    }
}
