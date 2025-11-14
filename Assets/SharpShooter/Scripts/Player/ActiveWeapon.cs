using StarterAssets;
using TMPro;
using Unity.Cinemachine;
using UnityEngine;


public class ActiveWeapon : MonoBehaviour
{
    [SerializeField] WeaponSO startingWeapon;//一開始拿的武器
    [SerializeField] CinemachineCamera playerFollowCamera;
    [SerializeField] Camera weaponCamera;//瞄準時的鏡頭
    [SerializeField] GameObject zoomVignette;
    [SerializeField] TMP_Text ammoText;

    WeaponSO CurrentweaponSO;// 「欄位」我目前拿的武器
    Animator animator;
    StarterAssetsInputs starterAssetsInputs;
    FirstPersonController firstPersonController;
    Weapon currentWeapon;

    float timeSinceLastShot = 0f;
    float defaultFOV;
    float defaultRotationSpeed;
    int currentAmmo;

    const string SHOOT_STRING = "Shoot";// 提煉成常數

    void Awake()
    {
        //向上尋找（在 parent 上）找到這個角色的輸入控制腳本
        starterAssetsInputs = GetComponentInParent<StarterAssetsInputs>();
        firstPersonController = GetComponentInParent<FirstPersonController>();
        //取得自己身上的 Animator
        animator = GetComponent<Animator>();
        //把目前相機的視角儲存起來，未來可以恢復
        defaultFOV = playerFollowCamera.Lens.FieldOfView;
        defaultRotationSpeed = firstPersonController.RotationSpeed;
    }
    void Start()
    {
        SwitchWeapon(startingWeapon);
        AdjustAmmo(CurrentweaponSO.MagazineSize);
    }

    void Update()
    {
        HandleShoot();
        HandleZoom();

    }

    public void AdjustAmmo(int amount)//子彈數量
    {
        currentAmmo += amount;
        // 如果加子彈後「超過彈匣最大容量」，就強制設回最大值。
        if (currentAmmo > CurrentweaponSO.MagazineSize)
        {
            currentAmmo = CurrentweaponSO.MagazineSize;
        }
        ammoText.text = currentAmmo.ToString("D2");//同步變更到顯示文字上

    }

    public void SwitchWeapon(WeaponSO weaponSO)// 「參數」外面送進來的武器
    {
        if (currentWeapon)
        {
            Destroy(currentWeapon.gameObject);
        }
        Weapon newWeapon = Instantiate(weaponSO.weaponPrefab, transform).GetComponent<Weapon>();
        //產生新的 weaponPrefab 並且 取得Weapon的腳本
        currentWeapon = newWeapon;
        this.CurrentweaponSO = weaponSO;
        AdjustAmmo(weaponSO.MagazineSize);

    }

    void HandleShoot()
    {
        timeSinceLastShot += Time.deltaTime;
        if (!starterAssetsInputs.shoot) return;
        if (timeSinceLastShot >= CurrentweaponSO.FireRate && currentAmmo > 0)//不成立的時候,就不能shot和play
        {
            currentWeapon.Shoot(CurrentweaponSO);
            animator.Play(SHOOT_STRING, 0, 0f);
            timeSinceLastShot = 0f;//cooldown
            AdjustAmmo(-1);
        }
        if (!CurrentweaponSO.IsAutomaic)
        {
            starterAssetsInputs.ShootInput(false);
        }
    }

    void HandleZoom()
    {
        if (!CurrentweaponSO.CanZoom) return;
        if (starterAssetsInputs.zoom)
        {
            playerFollowCamera.Lens.FieldOfView = CurrentweaponSO.ZoomAmount;
            weaponCamera.fieldOfView = CurrentweaponSO.ZoomAmount;//Zoomin單純只有鏡頭沒有武器
            zoomVignette.SetActive(true);
            firstPersonController.ChangeRotationSpeed(CurrentweaponSO.ZoomRotationSpeed);
        }
        else
        {
            playerFollowCamera.Lens.FieldOfView = defaultFOV;
            weaponCamera.fieldOfView = defaultFOV;
            zoomVignette.SetActive(false);
            firstPersonController.ChangeRotationSpeed(defaultRotationSpeed);
        }

    }
}
