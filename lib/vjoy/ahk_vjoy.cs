using System;
using System.Runtime.InteropServices;
using Nefarius.ViGEm.Client;
using Nefarius.ViGEm.Client.Targets;
using Nefarius.ViGEm.Client.Targets.Xbox360;

// 需要.NET 7.0 或更高版本, 编译指令: dotnet publish -p:NativeLib=Shared -r win-x64 -c Release
namespace ahk_vjoy
{
    public class ViGEmController
    {
        // 全局保存ViGEm客户端和虚拟手柄实例
        private static ViGEmClient? _client;
        private static IXbox360Controller? _xbox360Controller;
        private static bool _isInitialized = false;

        /// <summary>
        /// 初始化并连接虚拟Xbox 360手柄
        /// </summary>
        /// <returns>0=成功，1=已初始化，-1=失败</returns>
        [UnmanagedCallersOnly(EntryPoint = "InitXbox360Controller")]
        public static int InitXbox360Controller()
        {
            try
            {
                if (_isInitialized) return 1;

                _client = new ViGEmClient();
                // 创建手柄实例并转换为IXbox360Controller接口
                _xbox360Controller = _client.CreateXbox360Controller();
                if (_xbox360Controller == null) return -1;

                _xbox360Controller.Connect();
                _isInitialized = true;
                return 0;
            }
            catch (Exception)
            {
                return -1;
            }
        }

        /// <summary>
        /// 发送Xbox 360手柄输入（基于IXbox360Controller接口）
        /// </summary>
        /// <param name="buttons">按键位掩码（如A=1，B=2，组合则累加）</param>
        /// <param name="leftX">左摇杆X轴：-32768~32767</param>
        /// <param name="leftY">左摇杆Y轴：-32768~32767</param>
        /// <param name="rightX">右摇杆X轴：-32768~32767</param>
        /// <param name="rightY">右摇杆Y轴：-32768~32767</param>
        /// <param name="leftTrigger">左扳机：0~255</param>
        /// <param name="rightTrigger">右扳机：0~255</param>
        /// <returns>0=成功，-1=未初始化，-2=失败</returns>
        [UnmanagedCallersOnly(EntryPoint = "SendXbox360Input")]
        public static int SendXbox360Input(
            int buttons,
            short leftX, short leftY,
            short rightX, short rightY,
            byte leftTrigger, byte rightTrigger)
        {
            try
            {
                if (!_isInitialized || _xbox360Controller == null) return -1;

                // 方式1：使用接口提供的语义化方法设置状态（推荐，易读）
                // 1. 设置所有按键状态（位掩码方式）
                _xbox360Controller.SetButtonsFull((ushort)buttons);
                // 2. 设置摇杆轴值
                _xbox360Controller.SetAxisValue(Xbox360Axis.LeftThumbX, leftX);
                _xbox360Controller.SetAxisValue(Xbox360Axis.LeftThumbY, leftY);
                _xbox360Controller.SetAxisValue(Xbox360Axis.RightThumbX, rightX);
                _xbox360Controller.SetAxisValue(Xbox360Axis.RightThumbY, rightY);
                // 3. 设置扳机值
                _xbox360Controller.SetSliderValue(Xbox360Slider.LeftTrigger, leftTrigger);
                _xbox360Controller.SetSliderValue(Xbox360Slider.RightTrigger, rightTrigger);

                return 0;
            }
            catch (Exception)
            {
                return -2;
            }
        }

        /// <summary>
        /// 重置所有手柄输入（释放所有按键/摇杆归位）
        /// </summary>
        /// <returns>0=成功，-1=未初始化</returns>
        [UnmanagedCallersOnly(EntryPoint = "ResetXbox360Input")]
        public static int ResetXbox360Input()
        {
            try
            {
                if (!_isInitialized || _xbox360Controller == null) return -1;

                // 重置所有按键
                _xbox360Controller.SetButtonsFull(0);
                // 重置所有摇杆轴为0（居中）
                _xbox360Controller.SetAxisValue(Xbox360Axis.LeftThumbX, 0);
                _xbox360Controller.SetAxisValue(Xbox360Axis.LeftThumbY, 0);
                _xbox360Controller.SetAxisValue(Xbox360Axis.RightThumbX, 0);
                _xbox360Controller.SetAxisValue(Xbox360Axis.RightThumbY, 0);
                // 重置扳机为0（释放）
                _xbox360Controller.SetSliderValue(Xbox360Slider.LeftTrigger, 0);
                _xbox360Controller.SetSliderValue(Xbox360Slider.RightTrigger, 0);


                return 0;
            }
            catch (Exception)
            {
                return -1;
            }
        }

        /// <summary>
        /// 断开并释放虚拟手柄资源
        /// </summary>
        /// <returns>0=成功，-1=未初始化</returns>
        [UnmanagedCallersOnly(EntryPoint = "CloseXbox360Controller")]
        public static int CloseXbox360Controller()
        {
            try
            {
                if (!_isInitialized) return -1;

                _xbox360Controller?.Disconnect();
                _client?.Dispose();

                _isInitialized = false;
                _xbox360Controller = null;
                _client = null;
                return 0;
            }
            catch (Exception)
            {
                return -1;
            }
        }
    }
}