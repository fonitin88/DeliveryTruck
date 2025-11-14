using UnityEngine;
using UnityEngine.InputSystem;

public class Movement : MonoBehaviour
{
    [SerializeField] InputAction thrust;//輸入按鍵會有怎樣的動作
    [SerializeField] InputAction rotationZ;
    [SerializeField] InputAction rotationY;
    [SerializeField] float thrustStrength = 100f;
    [SerializeField] float rotationStrength = 100f;
    [SerializeField] AudioClip mainEngineSFX;
    [SerializeField] ParticleSystem mainEngineVFX;

    Rigidbody rb;
    AudioSource audioSource;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();

        audioSource = GetComponent<AudioSource>();

    }
    private void OnEnable()
    {
        thrust.Enable();
        rotationZ.Enable();
        rotationY.Enable();
    }
    private void FixedUpdate()
    {
        ProcessThrust();
        ProcessRotationZ();
        ProcessRotationY();
    }
    private void ProcessThrust()
    {
        if (thrust.IsPressed())
        {
            StartThrusting();
        }
        else
        {
            StopThrusting();
        }
    }
    private void StartThrusting()
    {
        rb.AddRelativeForce(transform.up * thrustStrength * Time.fixedDeltaTime);
        //press keybroad and have action
        if (mainEngineSFX != null && !audioSource.isPlaying)
        // 確認你有指定音效（不是空的） 確認音效目前沒有在播放
        {
            audioSource.PlayOneShot(mainEngineSFX);
        }

        if (mainEngineVFX != null && !mainEngineVFX.isPlaying)
        {
            mainEngineVFX.Play();
        }
    }
    private void StopThrusting()
    {
        if (audioSource != null)
        {
            audioSource.Stop();
        }

        if (mainEngineVFX != null)
        {
            mainEngineVFX.Stop();
        }
    }
    private void ProcessRotationZ()
    {
        float rotationInput = rotationZ.ReadValue<float>();
        float rotationAmount = -rotationInput * rotationStrength;
        ApplyRotationZ(rotationAmount);
    }
    private void ApplyRotationZ(float rotationAmount)
    {
        Vector3 currentRotation = transform.eulerAngles;
        float currentZ = transform.eulerAngles.z;
        if (currentZ > 180f)
        {
            currentZ -= 360f;
        }
        float newZ = currentZ + rotationAmount * Time.fixedDeltaTime;
        newZ = Mathf.Clamp(newZ, -30f, 0f);

        transform.rotation = Quaternion.Euler(0f, currentRotation.y, newZ);

    }
    private void ProcessRotationY()
    {
        float rotationInput = rotationY.ReadValue<float>();
        float rotationAmount = -rotationInput * rotationStrength;
        ApplyRotationY(rotationAmount);

    }
    private void ApplyRotationY(float rotationAmount)
    {
        Vector3 currentRotation = transform.eulerAngles;
        float currentY = transform.eulerAngles.y;
        if (currentY > 180f)
        {
            currentY -= 360f;
        }
        float newY = currentY + rotationAmount * Time.fixedDeltaTime;
        newY = Mathf.Clamp(newY, 0f, 90f);

        transform.rotation = Quaternion.Euler(0f, newY, currentRotation.z);
    }


}