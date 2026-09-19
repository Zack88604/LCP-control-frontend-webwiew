using System;
using System.Windows.Forms;

namespace LcpControlOnly
{
    internal static class Program
    {
        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            try
            {
                Application.Run(new CollectorForm());
            }
            catch (Exception exception)
            {
                MessageBox.Show(
                    "无法启动 LCP 采集控制：" + exception.Message,
                    "LCP 采集控制",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }
    }
}
