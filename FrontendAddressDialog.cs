using System.Drawing;
using System.Windows.Forms;

namespace LcpControlOnly
{
    internal sealed class FrontendAddressDialog : Form
    {
        private readonly TextBox addressTextBox;

        internal FrontendAddressDialog(string currentAddress)
        {
            Text = "前端地址设置";
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;
            ShowInTaskbar = false;
            StartPosition = FormStartPosition.CenterParent;
            ClientSize = new Size(640, 150);

            var label = new Label
            {
                AutoSize = true,
                Location = new Point(16, 16),
                Text = "LCP 前端地址",
            };
            addressTextBox = new TextBox
            {
                Location = new Point(16, 42),
                Size = new Size(608, 23),
                Text = currentAddress,
            };
            var hint = new Label
            {
                AutoSize = true,
                Location = new Point(16, 74),
                Text = "示例：http://192.168.50.32:5174/data-collection",
            };
            var saveButton = new Button
            {
                DialogResult = DialogResult.OK,
                Location = new Point(468, 108),
                Size = new Size(75, 27),
                Text = "保存",
            };
            var cancelButton = new Button
            {
                DialogResult = DialogResult.Cancel,
                Location = new Point(550, 108),
                Size = new Size(75, 27),
                Text = "取消",
            };

            Controls.Add(label);
            Controls.Add(addressTextBox);
            Controls.Add(hint);
            Controls.Add(saveButton);
            Controls.Add(cancelButton);
            AcceptButton = saveButton;
            CancelButton = cancelButton;
        }

        internal string FrontendAddress
        {
            get { return addressTextBox.Text; }
        }
    }
}
