function [] = get_convertion_example_panel(tabbed_panel)
% Conversion from Celsius to Fahrenheit example. Used to apply the 
% Netbeans IDE GUI to matlab handmade GUI.

    javaaddpath('C:\projects\behaviourPlatform\CommonScript\eeg\eeg_tools\gui\eeggui\dist\eeggui.jar')
    %javaaddpath('C:\Users\goccia\Documents\NetBeansProjects\JavaApplication8\dist\JavaApplication8.jar')
    %javaaddpath('C:\Users\goccia\Documents\NetBeansProjects\GUIFormExamples\dist\GUIFormExamples.jar')
    %%% Use this to use GImport
    %frame = GXJFrame(figure, 'myFrame', gui.NewJPanel());
    % or
    frame = GXJFrame(figure);
    g = GImport(frame, gui.basePanel(), false);
    ggg=GImport(figure(), gui.NewJPanel());
    %a = g.getComponents();
    %jbutton = a{10};  % More complicated
    %g.setCallback(jbutton, 'ActionPerformedCallback', @callback_print)
    
    %textfield = jbutton.name;
    
    
    mybutton = g.find('jButton1');   % Much easier to access the button.
    g.setCallback(mybutton, 'ActionPerformedCallback', @print_string, 'marcello')
    %%%%%

    global GlobalData

    import javax.swing.JFrame;
    import javax.swing.JPanel;
    import javax.swing.JLabel;
    import javax.swing.border.EmptyBorder;
    import javax.swing.JTextField;
    import java.awt.Color;
    import javax.swing.JCheckBox;
    import javax.swing.JComboBox;
    import javax.swing.JButton;
    import javax.swing.SpringLayout;
    import java.awt.BorderLayout;
    
    jPanel2 = javax.swing.JPanel();
    jPanel2Layout = javax.swing.GroupLayout(jPanel2);
    jPanel2.setLayout(jPanel2Layout);
    e = javaMethod('valueOf','javax.swing.GroupLayout$Alignment','LEADING');
    parallelGroup = jPanel2Layout.createParallelGroup(e);
    parallelGroup.addGap(0, 0, java.lang.Short.MAX_VALUE);
    jPanel2Layout.setHorizontalGroup(parallelGroup);
    
    
		contentPane = JPanel();
        tabbed_panel.addTab('test swing', contentPane);
        GlobalData.top_panel.add(tabbed_panel, java.awt.BorderLayout.CENTER);
        
		contentPane.setBorder(EmptyBorder(5, 5, 5, 5));
		%setContentPane(contentPane);
		sl_contentPane = SpringLayout();
		contentPane.setLayout(sl_contentPane);
		
		btnConvert = JButton('Convert');
		sl_contentPane.putConstraint(SpringLayout.NORTH, btnConvert, 10, SpringLayout.NORTH, contentPane);
		sl_contentPane.putConstraint(SpringLayout.WEST, btnConvert, 10, SpringLayout.WEST, contentPane);
		contentPane.add(btnConvert);
	
		txtTypeTextHere = JTextField();
		txtTypeTextHere.setText('Type text here');
		sl_contentPane.putConstraint(SpringLayout.NORTH, txtTypeTextHere, 6, SpringLayout.SOUTH, btnConvert);
		sl_contentPane.putConstraint(SpringLayout.WEST, txtTypeTextHere, 0, SpringLayout.WEST, btnConvert);
		contentPane.add(txtTypeTextHere);
		txtTypeTextHere.setColumns(10);
		
		lblMyPeersonalLabel = JLabel('My personal label');
		sl_contentPane.putConstraint(SpringLayout.WEST, lblMyPeersonalLabel, 22, SpringLayout.EAST, btnConvert);
		sl_contentPane.putConstraint(SpringLayout.SOUTH, lblMyPeersonalLabel, 0, SpringLayout.SOUTH, btnConvert);
		contentPane.add(lblMyPeersonalLabel);

    GlobalData.main_tabs.paths = contentPane;    
    
%     tempTextField = javax.swing.JTextField();
%     celsiusLabel = javax.swing.JLabel();
%     convertButton = javax.swing.JButton();
%     fahrenheitLabel = javax.swing.JLabel();
% 
%     tempTextField_handle = handle(tempTextField,'CallbackProperties');
%     set(tempTextField_handle, 'ActionPerformedCallback', @tempTextFieldActionPerformed);


    function tempTextFieldActionPerformed(varargin)                                              
    end                                       

    function convertButtonActionPerformed(varargin)                                              
        tempFahr = str2double(tempTextField.getText()) * 1.8 + 32;
        fahrenheitLabel.setText(strcat(tempFahr, ' Fahrenheit'));
    end 
end
                                            


