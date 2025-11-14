using UnityEngine;

[CreateAssetMenu(fileName = "WeaponSO", menuName = "Scriptable Objects/WeaponSO")]
public class WeaponSO : ScriptableObject
{
    public GameObject weaponPrefab;
    public int Demage = 1;
    public float FireRate = 1f;
    public GameObject HitVFXPrefab;
    public bool IsAutomaic = false;
    public bool CanZoom = false;
    public float ZoomAmount = 10f;
    public float ZoomRotationSpeed = 0.1f;
    public int MagazineSize = 12;
}
