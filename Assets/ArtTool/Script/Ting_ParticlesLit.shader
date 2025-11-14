Shader "Ting/pss_pbr"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _NormalStrenght("NormalStrenght", Range(0, 1)) = 1
        _Metallic("Metallic", Range(-1, 1)) = 0
        _Roughness("Roughness", Range(-1, 1)) = 0
        _Ao("Ao", Range(-1, 1)) = 0
        _Tiling("Tiling", Vector) = (1, 1, 0, 0)
        [NoScaleOffset]_BaseMap("BaseMap", 2D) = "white" {}
        [NoScaleOffset]_MraoMap("MraoMap", 2D) = "grey" {}
        [Normal][NoScaleOffset]_NormalMap("NormalMap", 2D) = "bump" {}
        [ToggleUI]_UseEmission("UseEmission", Float) = 0
        [HDR]_EmissionColor("EmissionColor", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_EmissionMap("EmissionMap", 2D) = "white" {}
        [HideInInspector]_LightIntensity("LightIntensity", Float) = 1
        [Toggle(_EMITTER)]_EMITTER("React to the Day/Night Cycle script", Float) = 1
        [ToggleUI]_UseOverlay("UseOverlay", Float) = 0
        _OverlayColor("OverlayColor", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_OverlayMap("OverlayMap", 2D) = "white" {}
        [ToggleUI]_UseVertexColor("UseVertexColor", Float) = 0
        _VertexColorStrenght("VertexColorStrenght", Range(0, 1)) = 1
        [ToggleUI]_UseDetail("UseDetail", Float) = 0
        _DetailTiling("DetailTiling", Range(0, 10)) = 2
        _DetailStrenght("DetailStrenght", Range(0, 1)) = 1
        [Normal][NoScaleOffset]_DetailMap("DetailMap", 2D) = "bump" {}
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
            "DisableBatching"="LODFading"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        AlphaToMask On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_SHADOW_COORD
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float2 staticLightmapUV;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float2 dynamicLightmapUV;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 sh;
            #endif
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 probeOcclusion;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 fogFactorAndVertexLight;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 shadowCoord;
            #endif
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 TangentSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float2 staticLightmapUV : INTERP0;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 sh : INTERP2;
            #endif
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 probeOcclusion : INTERP3;
            #endif
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 shadowCoord : INTERP4;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentWS : INTERP5;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP6;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2 : INTERP7;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : INTERP8;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 fogFactorAndVertexLight : INTERP9;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionWS : INTERP10;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS : INTERP11;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord2.xyzw = input.texCoord2;
            output.color.xyzw = input.color;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.color = input.color.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_ColorspaceConversion_RGB_Linear_float(float3 In, out float3 Out)
        {
            float3 linearRGBLo = In / 12.92;
            float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
            Out = float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
        {
            float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float3 result2 = 2.0 * Base * Blend;
            float3 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        struct Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float
        {
        half4 uv2;
        };
        
        void SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(float _UseOverlay, float3 _BaseColor, UnityTexture2D _OverlayMap, float4 _OverlayColor, Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float IN, out float3 Color_Out_1)
        {
        float _Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean = _UseOverlay;
        float3 _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3 = _BaseColor;
        float4 _Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4 = _OverlayColor;
        UnityTexture2D _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D = _OverlayMap;
        float4 _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.tex, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.samplerstate, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.GetTransformedUV(IN.uv2.xy) );
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_R_4_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.r;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_G_5_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.g;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_B_6_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.b;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_A_7_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.a;
        float4 _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4, _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4, _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4);
        float _Split_a8bbd4820cc24ebd810a82717a896710_R_1_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[0];
        float _Split_a8bbd4820cc24ebd810a82717a896710_G_2_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[1];
        float _Split_a8bbd4820cc24ebd810a82717a896710_B_3_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[2];
        float _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[3];
        float3 _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3;
        Unity_Blend_Overlay_float3(_Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, (_Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4.xyz), _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float);
        float3 _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        Unity_Branch_float3(_Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean, _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3);
        Color_Out_1 = _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float(float _Distance, float _DistanceFade, Bindings_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float IN, out float OutVector1_1)
        {
        float _Property_4d899d0efe944525916706ba671c98d2_Out_0_Float = _Distance;
        float _Property_afe8ed6dd9ad4dc28d5a25a0a101c7d9_Out_0_Float = _DistanceFade;
        float _Add_0805e01205084bda88aa502cc4a7ee51_Out_2_Float;
        Unity_Add_float(_Property_4d899d0efe944525916706ba671c98d2_Out_0_Float, _Property_afe8ed6dd9ad4dc28d5a25a0a101c7d9_Out_0_Float, _Add_0805e01205084bda88aa502cc4a7ee51_Out_2_Float);
        float _Distance_767176b1b3e54425b9e4d293bf5f1c85_Out_2_Float;
        Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_767176b1b3e54425b9e4d293bf5f1c85_Out_2_Float);
        float _Smoothstep_1a7e303fc0774ba8bfd8ebfc9bb7d4bf_Out_3_Float;
        Unity_Smoothstep_float(_Property_4d899d0efe944525916706ba671c98d2_Out_0_Float, _Add_0805e01205084bda88aa502cc4a7ee51_Out_2_Float, _Distance_767176b1b3e54425b9e4d293bf5f1c85_Out_2_Float, _Smoothstep_1a7e303fc0774ba8bfd8ebfc9bb7d4bf_Out_3_Float);
        OutVector1_1 = _Smoothstep_1a7e303fc0774ba8bfd8ebfc9bb7d4bf_Out_3_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        struct Bindings_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float(float _UseDetail, float3 _In_Normal, float _DetailStrenght, UnityTexture2D _DetailMap, float2 _UV, float _DetailTiling, Bindings_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float IN, out float3 Normal_Out_1)
        {
        float _Property_de00e6acaa9a43169eda59a62a02bbc7_Out_0_Boolean = _UseDetail;
        float3 _Property_23af9a033a174962890dabdc35d9d015_Out_0_Vector3 = _In_Normal;
        UnityTexture2D _Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D = _DetailMap;
        float2 _Property_9cca87c1bfcf42dba893b5e51a8aa883_Out_0_Vector2 = _UV;
        float _Property_4c15af891c6348fa8951fcff40829784_Out_0_Float = _DetailTiling;
        float2 _TilingAndOffset_75e483ca2c07441290733785f90d86a5_Out_3_Vector2;
        Unity_TilingAndOffset_float(_Property_9cca87c1bfcf42dba893b5e51a8aa883_Out_0_Vector2, (_Property_4c15af891c6348fa8951fcff40829784_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_75e483ca2c07441290733785f90d86a5_Out_3_Vector2);
        float4 _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D.tex, _Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D.samplerstate, _Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75e483ca2c07441290733785f90d86a5_Out_3_Vector2) );
        _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4);
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_R_4_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.r;
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_G_5_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.g;
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_B_6_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.b;
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_A_7_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.a;
        float _Property_4fb6e93a37914c4591d86da289328555_Out_0_Float = _DetailStrenght;
        Bindings_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335;
        _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335.WorldSpacePosition = IN.WorldSpacePosition;
        float _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335_OutVector1_1_Float;
        SG_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float(half(5), half(5), _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335, _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335_OutVector1_1_Float);
        float _OneMinus_c0889aa08037445f81e6aca860899bbc_Out_1_Float;
        Unity_OneMinus_float(_SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335_OutVector1_1_Float, _OneMinus_c0889aa08037445f81e6aca860899bbc_Out_1_Float);
        float _Multiply_095f11bdef5144eba256432f769d0ad5_Out_2_Float;
        Unity_Multiply_float_float(_Property_4fb6e93a37914c4591d86da289328555_Out_0_Float, _OneMinus_c0889aa08037445f81e6aca860899bbc_Out_1_Float, _Multiply_095f11bdef5144eba256432f769d0ad5_Out_2_Float);
        float3 _NormalStrength_b031a3d38ffc4d1dbf7a1ecaba445004_Out_2_Vector3;
        Unity_NormalStrength_float((_SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.xyz), _Multiply_095f11bdef5144eba256432f769d0ad5_Out_2_Float, _NormalStrength_b031a3d38ffc4d1dbf7a1ecaba445004_Out_2_Vector3);
        float3 _NormalBlend_c46f09d6e6b448dd9cbc11e958f935c5_Out_2_Vector3;
        Unity_NormalBlend_float(_Property_23af9a033a174962890dabdc35d9d015_Out_0_Vector3, _NormalStrength_b031a3d38ffc4d1dbf7a1ecaba445004_Out_2_Vector3, _NormalBlend_c46f09d6e6b448dd9cbc11e958f935c5_Out_2_Vector3);
        float3 _Branch_5cbb0aa30af946eabb7038afdbc2d964_Out_3_Vector3;
        Unity_Branch_float3(_Property_de00e6acaa9a43169eda59a62a02bbc7_Out_0_Boolean, _NormalBlend_c46f09d6e6b448dd9cbc11e958f935c5_Out_2_Vector3, _Property_23af9a033a174962890dabdc35d9d015_Out_0_Vector3, _Branch_5cbb0aa30af946eabb7038afdbc2d964_Out_3_Vector3);
        Normal_Out_1 = _Branch_5cbb0aa30af946eabb7038afdbc2d964_Out_3_Vector3;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        struct Bindings_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float
        {
        };
        
        void SG_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float(float _Metallic_In, float _Metallic_Offset, float _Roughness_In, float _Roughness_Offset, float _AO_In, float _Ao_Offset, Bindings_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float IN, out float Metallic_Out_2, out float Roughness_Out_1, out float AO_Out_3)
        {
        float _Property_d497117ba2c7493eaea92fa2965fbf43_Out_0_Float = _Metallic_In;
        float _Property_66ce63361eac48f99f700340d35f605d_Out_0_Float = _Metallic_Offset;
        float _Add_3cfde254c4aa43b1bca577f5027c9535_Out_2_Float;
        Unity_Add_float(_Property_d497117ba2c7493eaea92fa2965fbf43_Out_0_Float, _Property_66ce63361eac48f99f700340d35f605d_Out_0_Float, _Add_3cfde254c4aa43b1bca577f5027c9535_Out_2_Float);
        float _Saturate_5b19ad76182d494bb33c8ad54ca461cd_Out_1_Float;
        Unity_Saturate_float(_Add_3cfde254c4aa43b1bca577f5027c9535_Out_2_Float, _Saturate_5b19ad76182d494bb33c8ad54ca461cd_Out_1_Float);
        float _Property_3e10b8b231244a54b4a14b65c9e43377_Out_0_Float = _Roughness_In;
        float _Property_e00ca60395664f22aa26125fe7493810_Out_0_Float = _Roughness_Offset;
        float _Add_d6f771ec74fa44e588a3aae70ac5b073_Out_2_Float;
        Unity_Add_float(_Property_3e10b8b231244a54b4a14b65c9e43377_Out_0_Float, _Property_e00ca60395664f22aa26125fe7493810_Out_0_Float, _Add_d6f771ec74fa44e588a3aae70ac5b073_Out_2_Float);
        float _Saturate_bbd7d15159bb4100add3ac627cad3ef8_Out_1_Float;
        Unity_Saturate_float(_Add_d6f771ec74fa44e588a3aae70ac5b073_Out_2_Float, _Saturate_bbd7d15159bb4100add3ac627cad3ef8_Out_1_Float);
        float _OneMinus_dfe008d0dbe4483aa89ac1a47ba02e40_Out_1_Float;
        Unity_OneMinus_float(_Saturate_bbd7d15159bb4100add3ac627cad3ef8_Out_1_Float, _OneMinus_dfe008d0dbe4483aa89ac1a47ba02e40_Out_1_Float);
        float _Property_18ba6d237880403f944e3e1e882ab6f8_Out_0_Float = _AO_In;
        float _Property_f812ec0bf6cf4a8a983dd01b41692832_Out_0_Float = _Ao_Offset;
        float _Add_4187449e99c74d14bf7b2f19ac8a797d_Out_2_Float;
        Unity_Add_float(_Property_18ba6d237880403f944e3e1e882ab6f8_Out_0_Float, _Property_f812ec0bf6cf4a8a983dd01b41692832_Out_0_Float, _Add_4187449e99c74d14bf7b2f19ac8a797d_Out_2_Float);
        float _Saturate_58ea98fa82c24787ac58f3d4b43c2f10_Out_1_Float;
        Unity_Saturate_float(_Add_4187449e99c74d14bf7b2f19ac8a797d_Out_2_Float, _Saturate_58ea98fa82c24787ac58f3d4b43c2f10_Out_1_Float);
        Metallic_Out_2 = _Saturate_5b19ad76182d494bb33c8ad54ca461cd_Out_1_Float;
        Roughness_Out_1 = _OneMinus_dfe008d0dbe4483aa89ac1a47ba02e40_Out_1_Float;
        AO_Out_3 = _Saturate_58ea98fa82c24787ac58f3d4b43c2f10_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean = _UseOverlay;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean = _UseVertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3;
            Unity_ColorspaceConversion_RGB_Linear_float((IN.VertexColor.xyz), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_e079f804774244908d022d9b72152ead_Out_0_Float = _VertexColorStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3;
            Unity_Lerp_float3(float3(1, 1, 1), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3, (_Property_e079f804774244908d022d9b72152ead_Out_0_Float.xxx), _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3;
            Unity_Branch_float3(_Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean, _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3, float3(1, 1, 1), _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4, _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3, (_Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4.xyz), _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OverlayMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4 = _OverlayColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091;
            _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091.uv2 = IN.uv2;
            float3 _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(_Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean, _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3, _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D, _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_395b4f425b724090a94bd72fcbfe76e2_Out_0_Boolean = _UseDetail;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D.tex, _Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D.samplerstate, _Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4);
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_R_4_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.r;
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_G_5_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.g;
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_B_6_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.b;
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_A_7_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_89f745e989394e2a85f860a0022af99d_Out_0_Float = _NormalStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _NormalStrength_8a62b01377594c0797fde915e6e5eec5_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.xyz), _Property_89f745e989394e2a85f860a0022af99d_Out_0_Float, _NormalStrength_8a62b01377594c0797fde915e6e5eec5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_c5f77fcecace468db6e0d7341051a2eb_Out_0_Float = _DetailStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_e684b42fc0344cc5a673d60cce3ac5db_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_a24fa717e554433fa9d3eb58a93873a9_Out_0_Float = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37;
            _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37.WorldSpacePosition = IN.WorldSpacePosition;
            float3 _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37_NormalOut_1_Vector3;
            SG_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float(_Property_395b4f425b724090a94bd72fcbfe76e2_Out_0_Boolean, _NormalStrength_8a62b01377594c0797fde915e6e5eec5_Out_2_Vector3, _Property_c5f77fcecace468db6e0d7341051a2eb_Out_0_Float, _Property_e684b42fc0344cc5a673d60cce3ac5db_Out_0_Texture2D, _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2, _Property_a24fa717e554433fa9d3eb58a93873a9_Out_0_Float, _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37, _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37_NormalOut_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_4781e32741304a9a8966c9becb5303e0_Out_0_Boolean = _UseEmission;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_874f6b4f52b840eea1cce476acc33872_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EmissionMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D.tex, _Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D.samplerstate, _Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_R_4_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.r;
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_G_5_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.g;
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_B_6_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.b;
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_A_7_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_e780bff7c805403baaaaf0a1fcf1cf89_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_874f6b4f52b840eea1cce476acc33872_Out_0_Vector4, _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4, _Multiply_e780bff7c805403baaaaf0a1fcf1cf89_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_8102503112d744c9a1e96f43d4bcbf38_Out_0_Float = UNITY_ACCESS_HYBRID_INSTANCED_PROP(_LightIntensity, float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_bd06cfcf8f1c47fcb41c84a8524be5aa_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_e780bff7c805403baaaaf0a1fcf1cf89_Out_2_Vector4, (_Property_8102503112d744c9a1e96f43d4bcbf38_Out_0_Float.xxxx), _Multiply_bd06cfcf8f1c47fcb41c84a8524be5aa_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Branch_50a0f4471c3a46b786a41ce9df84e3d4_Out_3_Vector4;
            Unity_Branch_float4(_Property_4781e32741304a9a8966c9becb5303e0_Out_0_Boolean, _Multiply_bd06cfcf8f1c47fcb41c84a8524be5aa_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_50a0f4471c3a46b786a41ce9df84e3d4_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_3244d25dc6c3406c9122b998d59ed4ca_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MraoMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_3244d25dc6c3406c9122b998d59ed4ca_Out_0_Texture2D.tex, _Property_3244d25dc6c3406c9122b998d59ed4ca_Out_0_Texture2D.samplerstate, _Property_3244d25dc6c3406c9122b998d59ed4ca_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_R_4_Float = _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4.r;
            float _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_G_5_Float = _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4.g;
            float _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_B_6_Float = _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4.b;
            float _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_A_7_Float = _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_760676148c9f46088e59d0558f4bfd57_Out_0_Float = _Metallic;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_0949c715d317493188dfb4e6d6e9a02d_Out_0_Float = _Roughness;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_16ae2096b51f44c5b2f2bd799da382ed_Out_0_Float = _Ao;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae;
            float _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_MetallicOut_2_Float;
            float _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_RoughnessOut_1_Float;
            float _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_AOOut_3_Float;
            SG_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float(_SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_R_4_Float, _Property_760676148c9f46088e59d0558f4bfd57_Out_0_Float, _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_G_5_Float, _Property_0949c715d317493188dfb4e6d6e9a02d_Out_0_Float, _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_B_6_Float, _Property_16ae2096b51f44c5b2f2bd799da382ed_Out_0_Float, _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae, _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_MetallicOut_2_Float, _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_RoughnessOut_1_Float, _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_AOOut_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.BaseColor = _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            surface.NormalTS = _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37_NormalOut_1_Vector3;
            surface.Emission = (_Branch_50a0f4471c3a46b786a41ce9df84e3d4_Out_3_Vector4.xyz);
            surface.Metallic = _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_MetallicOut_2_Float;
            surface.Smoothness = _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_RoughnessOut_1_Float;
            surface.Occlusion = _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_AOOut_3_Float;
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv2 = input.texCoord2;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.VertexColor = input.color;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_SHADOW_COORD
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float2 staticLightmapUV;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float2 dynamicLightmapUV;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 sh;
            #endif
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 probeOcclusion;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 fogFactorAndVertexLight;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 shadowCoord;
            #endif
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 TangentSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float2 staticLightmapUV : INTERP0;
            #endif
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #endif
            #if !defined(LIGHTMAP_ON)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 sh : INTERP2;
            #endif
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 probeOcclusion : INTERP3;
            #endif
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 shadowCoord : INTERP4;
            #endif
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentWS : INTERP5;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP6;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2 : INTERP7;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : INTERP8;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 fogFactorAndVertexLight : INTERP9;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionWS : INTERP10;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS : INTERP11;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord2.xyzw = input.texCoord2;
            output.color.xyzw = input.color;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.color = input.color.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_ColorspaceConversion_RGB_Linear_float(float3 In, out float3 Out)
        {
            float3 linearRGBLo = In / 12.92;
            float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
            Out = float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
        {
            float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float3 result2 = 2.0 * Base * Blend;
            float3 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        struct Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float
        {
        half4 uv2;
        };
        
        void SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(float _UseOverlay, float3 _BaseColor, UnityTexture2D _OverlayMap, float4 _OverlayColor, Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float IN, out float3 Color_Out_1)
        {
        float _Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean = _UseOverlay;
        float3 _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3 = _BaseColor;
        float4 _Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4 = _OverlayColor;
        UnityTexture2D _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D = _OverlayMap;
        float4 _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.tex, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.samplerstate, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.GetTransformedUV(IN.uv2.xy) );
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_R_4_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.r;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_G_5_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.g;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_B_6_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.b;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_A_7_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.a;
        float4 _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4, _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4, _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4);
        float _Split_a8bbd4820cc24ebd810a82717a896710_R_1_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[0];
        float _Split_a8bbd4820cc24ebd810a82717a896710_G_2_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[1];
        float _Split_a8bbd4820cc24ebd810a82717a896710_B_3_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[2];
        float _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[3];
        float3 _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3;
        Unity_Blend_Overlay_float3(_Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, (_Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4.xyz), _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float);
        float3 _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        Unity_Branch_float3(_Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean, _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3);
        Color_Out_1 = _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float(float _Distance, float _DistanceFade, Bindings_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float IN, out float OutVector1_1)
        {
        float _Property_4d899d0efe944525916706ba671c98d2_Out_0_Float = _Distance;
        float _Property_afe8ed6dd9ad4dc28d5a25a0a101c7d9_Out_0_Float = _DistanceFade;
        float _Add_0805e01205084bda88aa502cc4a7ee51_Out_2_Float;
        Unity_Add_float(_Property_4d899d0efe944525916706ba671c98d2_Out_0_Float, _Property_afe8ed6dd9ad4dc28d5a25a0a101c7d9_Out_0_Float, _Add_0805e01205084bda88aa502cc4a7ee51_Out_2_Float);
        float _Distance_767176b1b3e54425b9e4d293bf5f1c85_Out_2_Float;
        Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_767176b1b3e54425b9e4d293bf5f1c85_Out_2_Float);
        float _Smoothstep_1a7e303fc0774ba8bfd8ebfc9bb7d4bf_Out_3_Float;
        Unity_Smoothstep_float(_Property_4d899d0efe944525916706ba671c98d2_Out_0_Float, _Add_0805e01205084bda88aa502cc4a7ee51_Out_2_Float, _Distance_767176b1b3e54425b9e4d293bf5f1c85_Out_2_Float, _Smoothstep_1a7e303fc0774ba8bfd8ebfc9bb7d4bf_Out_3_Float);
        OutVector1_1 = _Smoothstep_1a7e303fc0774ba8bfd8ebfc9bb7d4bf_Out_3_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        struct Bindings_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float(float _UseDetail, float3 _In_Normal, float _DetailStrenght, UnityTexture2D _DetailMap, float2 _UV, float _DetailTiling, Bindings_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float IN, out float3 Normal_Out_1)
        {
        float _Property_de00e6acaa9a43169eda59a62a02bbc7_Out_0_Boolean = _UseDetail;
        float3 _Property_23af9a033a174962890dabdc35d9d015_Out_0_Vector3 = _In_Normal;
        UnityTexture2D _Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D = _DetailMap;
        float2 _Property_9cca87c1bfcf42dba893b5e51a8aa883_Out_0_Vector2 = _UV;
        float _Property_4c15af891c6348fa8951fcff40829784_Out_0_Float = _DetailTiling;
        float2 _TilingAndOffset_75e483ca2c07441290733785f90d86a5_Out_3_Vector2;
        Unity_TilingAndOffset_float(_Property_9cca87c1bfcf42dba893b5e51a8aa883_Out_0_Vector2, (_Property_4c15af891c6348fa8951fcff40829784_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_75e483ca2c07441290733785f90d86a5_Out_3_Vector2);
        float4 _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D.tex, _Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D.samplerstate, _Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75e483ca2c07441290733785f90d86a5_Out_3_Vector2) );
        _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4);
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_R_4_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.r;
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_G_5_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.g;
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_B_6_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.b;
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_A_7_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.a;
        float _Property_4fb6e93a37914c4591d86da289328555_Out_0_Float = _DetailStrenght;
        Bindings_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335;
        _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335.WorldSpacePosition = IN.WorldSpacePosition;
        float _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335_OutVector1_1_Float;
        SG_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float(half(5), half(5), _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335, _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335_OutVector1_1_Float);
        float _OneMinus_c0889aa08037445f81e6aca860899bbc_Out_1_Float;
        Unity_OneMinus_float(_SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335_OutVector1_1_Float, _OneMinus_c0889aa08037445f81e6aca860899bbc_Out_1_Float);
        float _Multiply_095f11bdef5144eba256432f769d0ad5_Out_2_Float;
        Unity_Multiply_float_float(_Property_4fb6e93a37914c4591d86da289328555_Out_0_Float, _OneMinus_c0889aa08037445f81e6aca860899bbc_Out_1_Float, _Multiply_095f11bdef5144eba256432f769d0ad5_Out_2_Float);
        float3 _NormalStrength_b031a3d38ffc4d1dbf7a1ecaba445004_Out_2_Vector3;
        Unity_NormalStrength_float((_SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.xyz), _Multiply_095f11bdef5144eba256432f769d0ad5_Out_2_Float, _NormalStrength_b031a3d38ffc4d1dbf7a1ecaba445004_Out_2_Vector3);
        float3 _NormalBlend_c46f09d6e6b448dd9cbc11e958f935c5_Out_2_Vector3;
        Unity_NormalBlend_float(_Property_23af9a033a174962890dabdc35d9d015_Out_0_Vector3, _NormalStrength_b031a3d38ffc4d1dbf7a1ecaba445004_Out_2_Vector3, _NormalBlend_c46f09d6e6b448dd9cbc11e958f935c5_Out_2_Vector3);
        float3 _Branch_5cbb0aa30af946eabb7038afdbc2d964_Out_3_Vector3;
        Unity_Branch_float3(_Property_de00e6acaa9a43169eda59a62a02bbc7_Out_0_Boolean, _NormalBlend_c46f09d6e6b448dd9cbc11e958f935c5_Out_2_Vector3, _Property_23af9a033a174962890dabdc35d9d015_Out_0_Vector3, _Branch_5cbb0aa30af946eabb7038afdbc2d964_Out_3_Vector3);
        Normal_Out_1 = _Branch_5cbb0aa30af946eabb7038afdbc2d964_Out_3_Vector3;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        struct Bindings_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float
        {
        };
        
        void SG_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float(float _Metallic_In, float _Metallic_Offset, float _Roughness_In, float _Roughness_Offset, float _AO_In, float _Ao_Offset, Bindings_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float IN, out float Metallic_Out_2, out float Roughness_Out_1, out float AO_Out_3)
        {
        float _Property_d497117ba2c7493eaea92fa2965fbf43_Out_0_Float = _Metallic_In;
        float _Property_66ce63361eac48f99f700340d35f605d_Out_0_Float = _Metallic_Offset;
        float _Add_3cfde254c4aa43b1bca577f5027c9535_Out_2_Float;
        Unity_Add_float(_Property_d497117ba2c7493eaea92fa2965fbf43_Out_0_Float, _Property_66ce63361eac48f99f700340d35f605d_Out_0_Float, _Add_3cfde254c4aa43b1bca577f5027c9535_Out_2_Float);
        float _Saturate_5b19ad76182d494bb33c8ad54ca461cd_Out_1_Float;
        Unity_Saturate_float(_Add_3cfde254c4aa43b1bca577f5027c9535_Out_2_Float, _Saturate_5b19ad76182d494bb33c8ad54ca461cd_Out_1_Float);
        float _Property_3e10b8b231244a54b4a14b65c9e43377_Out_0_Float = _Roughness_In;
        float _Property_e00ca60395664f22aa26125fe7493810_Out_0_Float = _Roughness_Offset;
        float _Add_d6f771ec74fa44e588a3aae70ac5b073_Out_2_Float;
        Unity_Add_float(_Property_3e10b8b231244a54b4a14b65c9e43377_Out_0_Float, _Property_e00ca60395664f22aa26125fe7493810_Out_0_Float, _Add_d6f771ec74fa44e588a3aae70ac5b073_Out_2_Float);
        float _Saturate_bbd7d15159bb4100add3ac627cad3ef8_Out_1_Float;
        Unity_Saturate_float(_Add_d6f771ec74fa44e588a3aae70ac5b073_Out_2_Float, _Saturate_bbd7d15159bb4100add3ac627cad3ef8_Out_1_Float);
        float _OneMinus_dfe008d0dbe4483aa89ac1a47ba02e40_Out_1_Float;
        Unity_OneMinus_float(_Saturate_bbd7d15159bb4100add3ac627cad3ef8_Out_1_Float, _OneMinus_dfe008d0dbe4483aa89ac1a47ba02e40_Out_1_Float);
        float _Property_18ba6d237880403f944e3e1e882ab6f8_Out_0_Float = _AO_In;
        float _Property_f812ec0bf6cf4a8a983dd01b41692832_Out_0_Float = _Ao_Offset;
        float _Add_4187449e99c74d14bf7b2f19ac8a797d_Out_2_Float;
        Unity_Add_float(_Property_18ba6d237880403f944e3e1e882ab6f8_Out_0_Float, _Property_f812ec0bf6cf4a8a983dd01b41692832_Out_0_Float, _Add_4187449e99c74d14bf7b2f19ac8a797d_Out_2_Float);
        float _Saturate_58ea98fa82c24787ac58f3d4b43c2f10_Out_1_Float;
        Unity_Saturate_float(_Add_4187449e99c74d14bf7b2f19ac8a797d_Out_2_Float, _Saturate_58ea98fa82c24787ac58f3d4b43c2f10_Out_1_Float);
        Metallic_Out_2 = _Saturate_5b19ad76182d494bb33c8ad54ca461cd_Out_1_Float;
        Roughness_Out_1 = _OneMinus_dfe008d0dbe4483aa89ac1a47ba02e40_Out_1_Float;
        AO_Out_3 = _Saturate_58ea98fa82c24787ac58f3d4b43c2f10_Out_1_Float;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean = _UseOverlay;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean = _UseVertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3;
            Unity_ColorspaceConversion_RGB_Linear_float((IN.VertexColor.xyz), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_e079f804774244908d022d9b72152ead_Out_0_Float = _VertexColorStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3;
            Unity_Lerp_float3(float3(1, 1, 1), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3, (_Property_e079f804774244908d022d9b72152ead_Out_0_Float.xxx), _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3;
            Unity_Branch_float3(_Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean, _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3, float3(1, 1, 1), _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4, _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3, (_Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4.xyz), _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OverlayMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4 = _OverlayColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091;
            _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091.uv2 = IN.uv2;
            float3 _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(_Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean, _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3, _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D, _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_395b4f425b724090a94bd72fcbfe76e2_Out_0_Boolean = _UseDetail;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D.tex, _Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D.samplerstate, _Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4);
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_R_4_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.r;
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_G_5_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.g;
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_B_6_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.b;
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_A_7_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_89f745e989394e2a85f860a0022af99d_Out_0_Float = _NormalStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _NormalStrength_8a62b01377594c0797fde915e6e5eec5_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.xyz), _Property_89f745e989394e2a85f860a0022af99d_Out_0_Float, _NormalStrength_8a62b01377594c0797fde915e6e5eec5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_c5f77fcecace468db6e0d7341051a2eb_Out_0_Float = _DetailStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_e684b42fc0344cc5a673d60cce3ac5db_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_a24fa717e554433fa9d3eb58a93873a9_Out_0_Float = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37;
            _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37.WorldSpacePosition = IN.WorldSpacePosition;
            float3 _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37_NormalOut_1_Vector3;
            SG_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float(_Property_395b4f425b724090a94bd72fcbfe76e2_Out_0_Boolean, _NormalStrength_8a62b01377594c0797fde915e6e5eec5_Out_2_Vector3, _Property_c5f77fcecace468db6e0d7341051a2eb_Out_0_Float, _Property_e684b42fc0344cc5a673d60cce3ac5db_Out_0_Texture2D, _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2, _Property_a24fa717e554433fa9d3eb58a93873a9_Out_0_Float, _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37, _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37_NormalOut_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_4781e32741304a9a8966c9becb5303e0_Out_0_Boolean = _UseEmission;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_874f6b4f52b840eea1cce476acc33872_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EmissionMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D.tex, _Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D.samplerstate, _Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_R_4_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.r;
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_G_5_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.g;
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_B_6_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.b;
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_A_7_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_e780bff7c805403baaaaf0a1fcf1cf89_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_874f6b4f52b840eea1cce476acc33872_Out_0_Vector4, _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4, _Multiply_e780bff7c805403baaaaf0a1fcf1cf89_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_8102503112d744c9a1e96f43d4bcbf38_Out_0_Float = UNITY_ACCESS_HYBRID_INSTANCED_PROP(_LightIntensity, float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_bd06cfcf8f1c47fcb41c84a8524be5aa_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_e780bff7c805403baaaaf0a1fcf1cf89_Out_2_Vector4, (_Property_8102503112d744c9a1e96f43d4bcbf38_Out_0_Float.xxxx), _Multiply_bd06cfcf8f1c47fcb41c84a8524be5aa_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Branch_50a0f4471c3a46b786a41ce9df84e3d4_Out_3_Vector4;
            Unity_Branch_float4(_Property_4781e32741304a9a8966c9becb5303e0_Out_0_Boolean, _Multiply_bd06cfcf8f1c47fcb41c84a8524be5aa_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_50a0f4471c3a46b786a41ce9df84e3d4_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_3244d25dc6c3406c9122b998d59ed4ca_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MraoMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_3244d25dc6c3406c9122b998d59ed4ca_Out_0_Texture2D.tex, _Property_3244d25dc6c3406c9122b998d59ed4ca_Out_0_Texture2D.samplerstate, _Property_3244d25dc6c3406c9122b998d59ed4ca_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_R_4_Float = _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4.r;
            float _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_G_5_Float = _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4.g;
            float _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_B_6_Float = _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4.b;
            float _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_A_7_Float = _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_760676148c9f46088e59d0558f4bfd57_Out_0_Float = _Metallic;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_0949c715d317493188dfb4e6d6e9a02d_Out_0_Float = _Roughness;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_16ae2096b51f44c5b2f2bd799da382ed_Out_0_Float = _Ao;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae;
            float _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_MetallicOut_2_Float;
            float _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_RoughnessOut_1_Float;
            float _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_AOOut_3_Float;
            SG_SubGraphMRAOLevels_3eca1691b2bc5c04dbe7b9a9043b1f08_float(_SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_R_4_Float, _Property_760676148c9f46088e59d0558f4bfd57_Out_0_Float, _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_G_5_Float, _Property_0949c715d317493188dfb4e6d6e9a02d_Out_0_Float, _SampleTexture2D_6a6a2a99638f42a99f63ab888fb352b6_B_6_Float, _Property_16ae2096b51f44c5b2f2bd799da382ed_Out_0_Float, _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae, _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_MetallicOut_2_Float, _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_RoughnessOut_1_Float, _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_AOOut_3_Float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.BaseColor = _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            surface.NormalTS = _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37_NormalOut_1_Vector3;
            surface.Emission = (_Branch_50a0f4471c3a46b786a41ce9df84e3d4_Out_3_Vector4.xyz);
            surface.Metallic = _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_MetallicOut_2_Float;
            surface.Smoothness = _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_RoughnessOut_1_Float;
            surface.Occlusion = _SubGraphMRAOLevels_a10a248d191d4c67971a4eb187ea9fae_AOOut_3_Float;
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv2 = input.texCoord2;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.VertexColor = input.color;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS : INTERP1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LOD_FADE_CROSSFADE
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_POSITION_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_NORMAL_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TANGENT_WS
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        #define _ALPHATEST_ON 1
        #define USE_UNITY_CROSSFADE 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv1 : TEXCOORD1;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentWS;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 TangentSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 WorldSpacePosition;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentWS : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionWS : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalWS : INTERP3;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        struct Bindings_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float(float _Distance, float _DistanceFade, Bindings_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float IN, out float OutVector1_1)
        {
        float _Property_4d899d0efe944525916706ba671c98d2_Out_0_Float = _Distance;
        float _Property_afe8ed6dd9ad4dc28d5a25a0a101c7d9_Out_0_Float = _DistanceFade;
        float _Add_0805e01205084bda88aa502cc4a7ee51_Out_2_Float;
        Unity_Add_float(_Property_4d899d0efe944525916706ba671c98d2_Out_0_Float, _Property_afe8ed6dd9ad4dc28d5a25a0a101c7d9_Out_0_Float, _Add_0805e01205084bda88aa502cc4a7ee51_Out_2_Float);
        float _Distance_767176b1b3e54425b9e4d293bf5f1c85_Out_2_Float;
        Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_767176b1b3e54425b9e4d293bf5f1c85_Out_2_Float);
        float _Smoothstep_1a7e303fc0774ba8bfd8ebfc9bb7d4bf_Out_3_Float;
        Unity_Smoothstep_float(_Property_4d899d0efe944525916706ba671c98d2_Out_0_Float, _Add_0805e01205084bda88aa502cc4a7ee51_Out_2_Float, _Distance_767176b1b3e54425b9e4d293bf5f1c85_Out_2_Float, _Smoothstep_1a7e303fc0774ba8bfd8ebfc9bb7d4bf_Out_3_Float);
        OutVector1_1 = _Smoothstep_1a7e303fc0774ba8bfd8ebfc9bb7d4bf_Out_3_Float;
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
        Out = A * B;
        }
        
        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        struct Bindings_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float
        {
        float3 WorldSpacePosition;
        };
        
        void SG_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float(float _UseDetail, float3 _In_Normal, float _DetailStrenght, UnityTexture2D _DetailMap, float2 _UV, float _DetailTiling, Bindings_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float IN, out float3 Normal_Out_1)
        {
        float _Property_de00e6acaa9a43169eda59a62a02bbc7_Out_0_Boolean = _UseDetail;
        float3 _Property_23af9a033a174962890dabdc35d9d015_Out_0_Vector3 = _In_Normal;
        UnityTexture2D _Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D = _DetailMap;
        float2 _Property_9cca87c1bfcf42dba893b5e51a8aa883_Out_0_Vector2 = _UV;
        float _Property_4c15af891c6348fa8951fcff40829784_Out_0_Float = _DetailTiling;
        float2 _TilingAndOffset_75e483ca2c07441290733785f90d86a5_Out_3_Vector2;
        Unity_TilingAndOffset_float(_Property_9cca87c1bfcf42dba893b5e51a8aa883_Out_0_Vector2, (_Property_4c15af891c6348fa8951fcff40829784_Out_0_Float.xx), float2 (0, 0), _TilingAndOffset_75e483ca2c07441290733785f90d86a5_Out_3_Vector2);
        float4 _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D.tex, _Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D.samplerstate, _Property_7224e6071c214e9da08de53844cae138_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_75e483ca2c07441290733785f90d86a5_Out_3_Vector2) );
        _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4);
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_R_4_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.r;
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_G_5_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.g;
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_B_6_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.b;
        float _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_A_7_Float = _SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.a;
        float _Property_4fb6e93a37914c4591d86da289328555_Out_0_Float = _DetailStrenght;
        Bindings_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335;
        _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335.WorldSpacePosition = IN.WorldSpacePosition;
        float _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335_OutVector1_1_Float;
        SG_SubGraphDistanceSmoothStep_01abd5b89c45af64f9ced20c55d05fe0_float(half(5), half(5), _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335, _SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335_OutVector1_1_Float);
        float _OneMinus_c0889aa08037445f81e6aca860899bbc_Out_1_Float;
        Unity_OneMinus_float(_SubGraphDistanceSmoothStep_05d657d9ebcb4a6a9f9576a7f8c88335_OutVector1_1_Float, _OneMinus_c0889aa08037445f81e6aca860899bbc_Out_1_Float);
        float _Multiply_095f11bdef5144eba256432f769d0ad5_Out_2_Float;
        Unity_Multiply_float_float(_Property_4fb6e93a37914c4591d86da289328555_Out_0_Float, _OneMinus_c0889aa08037445f81e6aca860899bbc_Out_1_Float, _Multiply_095f11bdef5144eba256432f769d0ad5_Out_2_Float);
        float3 _NormalStrength_b031a3d38ffc4d1dbf7a1ecaba445004_Out_2_Vector3;
        Unity_NormalStrength_float((_SampleTexture2D_5f53aefe260641c3a6c7c1ab66315752_RGBA_0_Vector4.xyz), _Multiply_095f11bdef5144eba256432f769d0ad5_Out_2_Float, _NormalStrength_b031a3d38ffc4d1dbf7a1ecaba445004_Out_2_Vector3);
        float3 _NormalBlend_c46f09d6e6b448dd9cbc11e958f935c5_Out_2_Vector3;
        Unity_NormalBlend_float(_Property_23af9a033a174962890dabdc35d9d015_Out_0_Vector3, _NormalStrength_b031a3d38ffc4d1dbf7a1ecaba445004_Out_2_Vector3, _NormalBlend_c46f09d6e6b448dd9cbc11e958f935c5_Out_2_Vector3);
        float3 _Branch_5cbb0aa30af946eabb7038afdbc2d964_Out_3_Vector3;
        Unity_Branch_float3(_Property_de00e6acaa9a43169eda59a62a02bbc7_Out_0_Boolean, _NormalBlend_c46f09d6e6b448dd9cbc11e958f935c5_Out_2_Vector3, _Property_23af9a033a174962890dabdc35d9d015_Out_0_Vector3, _Branch_5cbb0aa30af946eabb7038afdbc2d964_Out_3_Vector3);
        Normal_Out_1 = _Branch_5cbb0aa30af946eabb7038afdbc2d964_Out_3_Vector3;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_395b4f425b724090a94bd72fcbfe76e2_Out_0_Boolean = _UseDetail;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D.tex, _Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D.samplerstate, _Property_836cd28f9a5b4d36808e1fb80f3bd1d6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4);
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_R_4_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.r;
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_G_5_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.g;
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_B_6_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.b;
            float _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_A_7_Float = _SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_89f745e989394e2a85f860a0022af99d_Out_0_Float = _NormalStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _NormalStrength_8a62b01377594c0797fde915e6e5eec5_Out_2_Vector3;
            Unity_NormalStrength_float((_SampleTexture2D_8d975b9c0e234457b9dcf20654fc1ac5_RGBA_0_Vector4.xyz), _Property_89f745e989394e2a85f860a0022af99d_Out_0_Float, _NormalStrength_8a62b01377594c0797fde915e6e5eec5_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_c5f77fcecace468db6e0d7341051a2eb_Out_0_Float = _DetailStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_e684b42fc0344cc5a673d60cce3ac5db_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_DetailMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_a24fa717e554433fa9d3eb58a93873a9_Out_0_Float = _DetailTiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37;
            _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37.WorldSpacePosition = IN.WorldSpacePosition;
            float3 _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37_NormalOut_1_Vector3;
            SG_SubGraphDetailNormalMapBlend_882269baf9cf65a499f10ef29466c627_float(_Property_395b4f425b724090a94bd72fcbfe76e2_Out_0_Boolean, _NormalStrength_8a62b01377594c0797fde915e6e5eec5_Out_2_Vector3, _Property_c5f77fcecace468db6e0d7341051a2eb_Out_0_Float, _Property_e684b42fc0344cc5a673d60cce3ac5db_Out_0_Texture2D, _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2, _Property_a24fa717e554433fa9d3eb58a93873a9_Out_0_Float, _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37, _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37_NormalOut_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.NormalTS = _SubGraphDetailNormalMapBlend_b163a9c56410445c9835511c1bd7aa37_NormalOut_1_Vector3;
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        #endif
        
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.WorldSpacePosition = input.positionWS;
        #endif
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_INSTANCEID
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv1 : TEXCOORD1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord1 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2 : INTERP2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : INTERP3;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_ColorspaceConversion_RGB_Linear_float(float3 In, out float3 Out)
        {
            float3 linearRGBLo = In / 12.92;
            float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
            Out = float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
        {
            float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float3 result2 = 2.0 * Base * Blend;
            float3 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        struct Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float
        {
        half4 uv2;
        };
        
        void SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(float _UseOverlay, float3 _BaseColor, UnityTexture2D _OverlayMap, float4 _OverlayColor, Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float IN, out float3 Color_Out_1)
        {
        float _Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean = _UseOverlay;
        float3 _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3 = _BaseColor;
        float4 _Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4 = _OverlayColor;
        UnityTexture2D _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D = _OverlayMap;
        float4 _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.tex, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.samplerstate, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.GetTransformedUV(IN.uv2.xy) );
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_R_4_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.r;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_G_5_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.g;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_B_6_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.b;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_A_7_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.a;
        float4 _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4, _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4, _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4);
        float _Split_a8bbd4820cc24ebd810a82717a896710_R_1_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[0];
        float _Split_a8bbd4820cc24ebd810a82717a896710_G_2_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[1];
        float _Split_a8bbd4820cc24ebd810a82717a896710_B_3_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[2];
        float _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[3];
        float3 _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3;
        Unity_Blend_Overlay_float3(_Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, (_Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4.xyz), _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float);
        float3 _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        Unity_Branch_float3(_Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean, _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3);
        Color_Out_1 = _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        }
        
        void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean = _UseOverlay;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean = _UseVertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3;
            Unity_ColorspaceConversion_RGB_Linear_float((IN.VertexColor.xyz), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_e079f804774244908d022d9b72152ead_Out_0_Float = _VertexColorStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3;
            Unity_Lerp_float3(float3(1, 1, 1), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3, (_Property_e079f804774244908d022d9b72152ead_Out_0_Float.xxx), _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3;
            Unity_Branch_float3(_Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean, _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3, float3(1, 1, 1), _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4, _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3, (_Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4.xyz), _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OverlayMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4 = _OverlayColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091;
            _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091.uv2 = IN.uv2;
            float3 _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(_Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean, _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3, _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D, _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_4781e32741304a9a8966c9becb5303e0_Out_0_Boolean = _UseEmission;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_874f6b4f52b840eea1cce476acc33872_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_EmissionMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D.tex, _Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D.samplerstate, _Property_417ed048f8004da18bb811bf4f80c82a_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_R_4_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.r;
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_G_5_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.g;
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_B_6_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.b;
            float _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_A_7_Float = _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_e780bff7c805403baaaaf0a1fcf1cf89_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_874f6b4f52b840eea1cce476acc33872_Out_0_Vector4, _SampleTexture2D_ed1a999640ef4484a370a487eb5e12df_RGBA_0_Vector4, _Multiply_e780bff7c805403baaaaf0a1fcf1cf89_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_8102503112d744c9a1e96f43d4bcbf38_Out_0_Float = UNITY_ACCESS_HYBRID_INSTANCED_PROP(_LightIntensity, float);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_bd06cfcf8f1c47fcb41c84a8524be5aa_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Multiply_e780bff7c805403baaaaf0a1fcf1cf89_Out_2_Vector4, (_Property_8102503112d744c9a1e96f43d4bcbf38_Out_0_Float.xxxx), _Multiply_bd06cfcf8f1c47fcb41c84a8524be5aa_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Branch_50a0f4471c3a46b786a41ce9df84e3d4_Out_3_Vector4;
            Unity_Branch_float4(_Property_4781e32741304a9a8966c9becb5303e0_Out_0_Boolean, _Multiply_bd06cfcf8f1c47fcb41c84a8524be5aa_Out_2_Vector4, float4(0, 0, 0, 0), _Branch_50a0f4471c3a46b786a41ce9df84e3d4_Out_3_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.BaseColor = _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            surface.Emission = (_Branch_50a0f4471c3a46b786a41ce9df84e3d4_Out_3_Vector4.xyz);
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv2 = input.texCoord2;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.VertexColor = input.color;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP0;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord2.xyzw = input.texCoord2;
            output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_ColorspaceConversion_RGB_Linear_float(float3 In, out float3 Out)
        {
            float3 linearRGBLo = In / 12.92;
            float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
            Out = float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
        {
            float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float3 result2 = 2.0 * Base * Blend;
            float3 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        struct Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float
        {
        half4 uv2;
        };
        
        void SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(float _UseOverlay, float3 _BaseColor, UnityTexture2D _OverlayMap, float4 _OverlayColor, Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float IN, out float3 Color_Out_1)
        {
        float _Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean = _UseOverlay;
        float3 _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3 = _BaseColor;
        float4 _Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4 = _OverlayColor;
        UnityTexture2D _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D = _OverlayMap;
        float4 _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.tex, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.samplerstate, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.GetTransformedUV(IN.uv2.xy) );
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_R_4_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.r;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_G_5_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.g;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_B_6_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.b;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_A_7_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.a;
        float4 _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4, _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4, _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4);
        float _Split_a8bbd4820cc24ebd810a82717a896710_R_1_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[0];
        float _Split_a8bbd4820cc24ebd810a82717a896710_G_2_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[1];
        float _Split_a8bbd4820cc24ebd810a82717a896710_B_3_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[2];
        float _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[3];
        float3 _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3;
        Unity_Blend_Overlay_float3(_Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, (_Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4.xyz), _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float);
        float3 _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        Unity_Branch_float3(_Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean, _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3);
        Color_Out_1 = _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean = _UseOverlay;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean = _UseVertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3;
            Unity_ColorspaceConversion_RGB_Linear_float((IN.VertexColor.xyz), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_e079f804774244908d022d9b72152ead_Out_0_Float = _VertexColorStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3;
            Unity_Lerp_float3(float3(1, 1, 1), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3, (_Property_e079f804774244908d022d9b72152ead_Out_0_Float.xxx), _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3;
            Unity_Branch_float3(_Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean, _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3, float3(1, 1, 1), _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4, _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3, (_Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4.xyz), _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OverlayMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4 = _OverlayColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091;
            _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091.uv2 = IN.uv2;
            float3 _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(_Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean, _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3, _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D, _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.BaseColor = _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv2 = input.texCoord2;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.VertexColor = input.color;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        #pragma shader_feature_local _ _EMITTER
        
        #if defined(_EMITTER)
            #define KEYWORD_PERMUTATION_0
        #else
            #define KEYWORD_PERMUTATION_1
        #endif
        
        
        // Defines
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMALMAP 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define _NORMAL_DROPOFF_TS 1
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_NORMAL
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TANGENT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define ATTRIBUTES_NEED_COLOR
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD0
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_TEXCOORD2
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        #define VARYINGS_NEED_COLOR
        #endif
        
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        #define _ALPHATEST_ON 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 positionOS : POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 normalOS : NORMAL;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 tangentOS : TANGENT;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0 : TEXCOORD0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2 : TEXCOORD2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : COLOR;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
            #endif
        };
        struct Varyings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 uv2;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 VertexColor;
            #endif
        };
        struct VertexDescriptionInputs
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceNormal;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpaceTangent;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float3 ObjectSpacePosition;
            #endif
        };
        struct PackedVaryings
        {
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 positionCS : SV_POSITION;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord0 : INTERP0;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 texCoord2 : INTERP1;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             float4 color : INTERP2;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
            #endif
        };
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord2.xyzw = input.texCoord2;
            output.color.xyzw = input.color;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.color = input.color.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        #endif
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _BaseMap_TexelSize;
        float4 _NormalMap_TexelSize;
        float4 _MraoMap_TexelSize;
        float _NormalStrenght;
        float _Roughness;
        float4 _Color;
        float2 _Tiling;
        float _UseVertexColor;
        float _VertexColorStrenght;
        float _Metallic;
        float _UseEmission;
        float4 _EmissionMap_TexelSize;
        float _Ao;
        float4 _EmissionColor;
        float _UseOverlay;
        float4 _OverlayMap_TexelSize;
        float4 _OverlayColor;
        float4 _DetailMap_TexelSize;
        float _UseDetail;
        float _DetailTiling;
        float _DetailStrenght;
        float _LightIntensity;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        #if defined(DOTS_INSTANCING_ON)
        // DOTS instancing definitions
        UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
            UNITY_DOTS_INSTANCED_PROP_OVERRIDE_SUPPORTED(float, _LightIntensity)
        UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)
        // DOTS instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_DOTS_INSTANCED_PROP_WITH_DEFAULT(type, var)
        #elif defined(UNITY_INSTANCING_ENABLED)
        // Unity instancing definitions
        UNITY_INSTANCING_BUFFER_START(SGPerInstanceData)
            UNITY_DEFINE_INSTANCED_PROP(float, _LightIntensity)
        UNITY_INSTANCING_BUFFER_END(SGPerInstanceData)
        // Unity instancing usage macros
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) UNITY_ACCESS_INSTANCED_PROP(SGPerInstanceData, var)
        #else
        #define UNITY_ACCESS_HYBRID_INSTANCED_PROP(var, type) var
        #endif
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_MraoMap);
        SAMPLER(sampler_MraoMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);
        TEXTURE2D(_OverlayMap);
        SAMPLER(sampler_OverlayMap);
        TEXTURE2D(_DetailMap);
        SAMPLER(sampler_DetailMap);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_ColorspaceConversion_RGB_Linear_float(float3 In, out float3 Out)
        {
            float3 linearRGBLo = In / 12.92;
            float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
            Out = float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
        }
        
        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }
        
        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Blend_Overlay_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
        {
            float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float3 result2 = 2.0 * Base * Blend;
            float3 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }
        
        struct Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float
        {
        half4 uv2;
        };
        
        void SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(float _UseOverlay, float3 _BaseColor, UnityTexture2D _OverlayMap, float4 _OverlayColor, Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float IN, out float3 Color_Out_1)
        {
        float _Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean = _UseOverlay;
        float3 _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3 = _BaseColor;
        float4 _Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4 = _OverlayColor;
        UnityTexture2D _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D = _OverlayMap;
        float4 _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.tex, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.samplerstate, _Property_ecfadccba71d414e98752cbde8f25e55_Out_0_Texture2D.GetTransformedUV(IN.uv2.xy) );
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_R_4_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.r;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_G_5_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.g;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_B_6_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.b;
        float _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_A_7_Float = _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4.a;
        float4 _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4;
        Unity_Multiply_float4_float4(_Property_7e70d9d8c52740418741dc689f58f1dd_Out_0_Vector4, _SampleTexture2D_b4d4ff144aff49f49be88163eaeaf6da_RGBA_0_Vector4, _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4);
        float _Split_a8bbd4820cc24ebd810a82717a896710_R_1_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[0];
        float _Split_a8bbd4820cc24ebd810a82717a896710_G_2_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[1];
        float _Split_a8bbd4820cc24ebd810a82717a896710_B_3_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[2];
        float _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float = _Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4[3];
        float3 _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3;
        Unity_Blend_Overlay_float3(_Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, (_Multiply_0b302752efe24850ba3274b8eb528023_Out_2_Vector4.xyz), _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Split_a8bbd4820cc24ebd810a82717a896710_A_4_Float);
        float3 _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        Unity_Branch_float3(_Property_01231acbed5a4dc499dec5e654d7e4b1_Out_0_Boolean, _Blend_3fef9e6932684f1c8c86768e37157716_Out_2_Vector3, _Property_07ee401a7a584149a88c49afbe9aa047_Out_0_Vector3, _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3);
        Color_Out_1 = _Branch_eb49f7d5b9ee40e1b7a1fe1e805cab64_Out_3_Vector3;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean = _UseOverlay;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean = _UseVertexColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3;
            Unity_ColorspaceConversion_RGB_Linear_float((IN.VertexColor.xyz), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Property_e079f804774244908d022d9b72152ead_Out_0_Float = _VertexColorStrenght;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3;
            Unity_Lerp_float3(float3(1, 1, 1), _ColorspaceConversion_9917a16a4b2c49bea06f6ad3135eca69_Out_1_Vector3, (_Property_e079f804774244908d022d9b72152ead_Out_0_Float.xxx), _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3;
            Unity_Branch_float3(_Property_d1302a29e7434670b921ffe62a0ad311_Out_0_Boolean, _Lerp_37a9c46fbaa144cfa47466270a4eaefa_Out_3_Vector3, float3(1, 1, 1), _Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4 = _Color;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_BaseMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2 = _Tiling;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float2 _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_973c9aad61374d7188f146f22fe87921_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.tex, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.samplerstate, _Property_9a7aab55e66f4935821cd1bac505019e_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_5f09686417e84e82b1d77cb4ccec1748_Out_3_Vector2) );
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_R_4_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.r;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_G_5_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.g;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_B_6_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.b;
            float _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float = _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4.a;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4;
            Unity_Multiply_float4_float4(_Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_RGBA_0_Vector4, _Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float3 _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3;
            Unity_Multiply_float3_float3(_Branch_d0c1548c3d394a728a8a99b511a31425_Out_3_Vector3, (_Multiply_677fe6262ba3408b895f57564f0a4b0f_Out_2_Vector4.xyz), _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            UnityTexture2D _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_OverlayMap);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float4 _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4 = _OverlayColor;
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            Bindings_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091;
            _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091.uv2 = IN.uv2;
            float3 _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            SG_SubGraphOverlay_4b6c687d0f28b754193735f1e0dd3c58_float(_Property_79d507a1a92c47b883d7a46d86a11ad1_Out_0_Boolean, _Multiply_b0b8199ede694317891802aa0436b849_Out_2_Vector3, _Property_5e6d4a811d43436f8082d6476812626f_Out_0_Texture2D, _Property_86c3e67263a942e9bc255099c6d12e6a_Out_0_Vector4, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091, _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3);
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_R_1_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[0];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_G_2_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[1];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_B_3_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[2];
            float _Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float = _Property_eb8ab368c36443dbaaf9937faaab324f_Out_0_Vector4[3];
            #endif
            #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
            float _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            Unity_Multiply_float_float(_Split_ad23f87eb02f4f14afa9b8985b3d5abf_A_4_Float, _SampleTexture2D_8829af05608a4352acfa6d21d75cd7db_A_7_Float, _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float);
            #endif
            surface.BaseColor = _SubGraphOverlay_82f48f8d9b5045dc82e8a2fdc992e091_ColorOut_1_Vector3;
            surface.Alpha = _Multiply_08773d07f66442b891a3aa220f966a59_Out_2_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceNormal =                          input.normalOS;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.ObjectSpacePosition =                        input.positionOS;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv0 = input.texCoord0;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.uv2 = input.texCoord2;
        #endif
        
        #if defined(KEYWORD_PERMUTATION_0) || defined(KEYWORD_PERMUTATION_1)
        output.VertexColor = input.color;
        #endif
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}