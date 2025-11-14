using System.Collections;
using Unity.Cinemachine;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    [SerializeField] ParticleSystem SpeedUpParticleSystem;
    [SerializeField] float minFOV = 20f;
    [SerializeField] float maxFOV = 120;
    [SerializeField] float zoomDuration = 1f;//從原本的FOV慢慢變到目標FOV的時間
    [SerializeField] float zoomSpeedModifier = 5f;//加快zoom的速度

    CinemachineCamera cinemachineCamera;

    void Awake()
    {
        cinemachineCamera = GetComponent<CinemachineCamera>();
        //CinemachineCamera 實例,Unity不會自動知道你要控制哪個 component，要你自己明確指定。
    }

    public void ChangeCameraFOV(float speedAmount)
    {
        StopAllCoroutines();//確保停止用coroutines後在進行下一行
        StartCoroutine(ChangeFOVRoutine(speedAmount));

        if (speedAmount > 0)
        {
            SpeedUpParticleSystem.Play();
        }
    }

    IEnumerator ChangeFOVRoutine(float speedAmount)
    {
        float startFOV = cinemachineCamera.Lens.FieldOfView;
        //限制最終的視角範圍在合理區間內
        float targetFOV = Mathf.Clamp(startFOV + speedAmount * zoomSpeedModifier, minFOV, maxFOV);

        float elapsedTime = 0f;

        while (elapsedTime < zoomDuration)
        {
            float t = elapsedTime / zoomDuration;//把「目前已經過的時間」換算成進度百分比
            elapsedTime += Time.deltaTime;
            cinemachineCamera.Lens.FieldOfView = Mathf.Lerp(startFOV, targetFOV, t);
            yield return null;//暫停這一幀，等下一幀再繼續執行 while 迴圈
        }
        cinemachineCamera.Lens.FieldOfView = targetFOV;

    }
}
