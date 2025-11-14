using Unity.Cinemachine;
using UnityEngine;

public class Weapon : MonoBehaviour
{
    [SerializeField] ParticleSystem muzzleFlash;
    [SerializeField] LayerMask interactionLayers;//讓發射作用在不同layer上

    CinemachineImpulseSource impulseSource;//鏡頭震動

    void Awake()
    {
        impulseSource = GetComponent<CinemachineImpulseSource>();
    }

    public void Shoot(WeaponSO weaponSO)
    {
        muzzleFlash.Play();
        impulseSource.GenerateImpulse();//鏡頭震動

        RaycastHit hit;

        if (Physics.Raycast(Camera.main.transform.position, Camera.main.transform.forward, out hit, Mathf.Infinity, interactionLayers, QueryTriggerInteraction.Ignore))
        {
            Instantiate(weaponSO.HitVFXPrefab, hit.point, Quaternion.identity);
            EnemyHealth enemyHealth = hit.collider.GetComponentInParent<EnemyHealth>();
            //打中的敵人身上的 EnemyHealth腳本
            enemyHealth?.TakeDamage(weaponSO.Demage);
            //當我們真的找到 EnemyHealth 腳本時，才執行扣血
        }
    }
}
