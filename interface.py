import casino
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.backends.backend_tkagg as tkagg
import customtkinter

customtkinter.set_appearance_mode("System")
customtkinter.set_default_color_theme("blue")

class App(customtkinter.CTk):
    def __init__(self):
        super().__init__()

        # configure window
        self.title("CustomTkinter complex_example.py")
        self.geometry(f"{1100}x{580}")

        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

        # create sidebar frame with widgets
        self.sidebar_frame = customtkinter.CTkFrame(self, corner_radius=0)
        self.sidebar_frame.grid(row=0, column=0, sticky="nsew")
        self.sidebar_frame.grid_rowconfigure(5, weight=1)

        self.logo_label = customtkinter.CTkLabel(
            self.sidebar_frame,
            text="Paramètres",
            font=customtkinter.CTkFont(size=20, weight="bold"),
        )
        self.logo_label.grid(row=0, column=0, padx=20, pady=(20, 10))

        self.alpha_label = customtkinter.CTkLabel(self.sidebar_frame, text="Alpha : 1")
        self.alpha_label.grid(
            row=1, column=0, padx=(20, 10), pady=(10, 10), sticky="ew"
        )
        self.alpha_slider = customtkinter.CTkSlider(
            self.sidebar_frame, from_=0.1, to=5, number_of_steps=100
        )
        self.alpha_slider.grid(
            row=2, column=0, padx=(20, 10), pady=(10, 10), sticky="ew"
        )
        self.alpha_slider.set(1)
        self.alpha_slider.configure(
            command=lambda x: self.alpha_label.configure(
                text="Alpha : {:.2f}".format(x)
            )
        )

        self.y_label = customtkinter.CTkLabel(
            self.sidebar_frame, text="Capital initial : 500"
        )
        self.y_label.grid(row=3, column=0, padx=(20, 10), pady=(10, 10), sticky="ew")
        self.y_slider = customtkinter.CTkSlider(
            self.sidebar_frame, from_=0, to=1000, number_of_steps=10000
        )
        self.y_slider.set(500)
        self.y_slider.grid(row=4, column=0, padx=(20, 10), pady=(10, 10), sticky="ew")
        self.y_slider.configure(
            command=lambda x: self.y_label.configure(
                text="Capital initial : {:.2f}".format(x)
            )
        )
        self.sidebar_button_1 = customtkinter.CTkButton(
            self.sidebar_frame, text="Simuler"
        )
        self.sidebar_button_1.grid(row=6, column=0, padx=20, pady=10)
        self.sidebar_button_1.configure(command=self.simulate_casino)

        # create plot zone
        self.plot_frame = customtkinter.CTkFrame(self)
        self.plot_frame.grid(row=0, column=1, sticky="nsew")
        self.fig = plt.figure(dpi=72)

        self.ax = self.fig.add_subplot(111)
        self.canvas = tkagg.FigureCanvasTkAgg(self.fig, master=self.plot_frame)
        self.canvas.draw()
        self.canvas.get_tk_widget().pack(
            side=customtkinter.TOP, fill=customtkinter.BOTH, expand=1
        )

    def simulate_casino(self):
        alpha = self.alpha_slider.get()
        Y0 = self.y_slider.get()
        duration = 1000
        casino_earnings, player_earnings, casino_capital = casino.casino_simulation(
            alpha, Y0, duration, lambda n: np.random.exponential(size=n)
        )

        self.ax.clear()
        self.ax.plot(casino_earnings, label="Casino Earnings")
        self.ax.plot(player_earnings, label="Player Earnings")
        self.ax.plot(casino_capital, label="Casino Capital")
        self.ax.legend()
        self.canvas.draw()


if __name__ == "__main__":
    app = App()
    app.mainloop()
