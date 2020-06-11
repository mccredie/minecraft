
export const timeout = (duration) => {
    return new Promise((resolve, reject) => {
        try {
            setTimeout(resolve, duration);
        } catch(error) {
            reject(error);
        }
    });
};
